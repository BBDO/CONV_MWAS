//
//      MOON WALK ALL STAR - iOS version
//      Purpose of this app is to capture data from the OSX app
//      via OSC which controls the image rotation and background colors.
//
//      Developed by Jason Walters/BBDO
//      Copyright 2013
//
//      Last revision by Jason Walters on June 17th, 2013
//      Compatible with openFrameworks 0074
//
///////////////////////////////////////////////////////////////

#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup(){
    
	// listen on the given port
	cout << "listening for osc messages on port " << PORT << "\n";
	receiver.setup( PORT );
    
	current_msg_string = 0;
    
    imgShoe.loadImage("converse.png");
    imgLogo.loadImage("converse-logo.jpg");
    
    iSteps = 0;
    
    font.loadFont("samsrg.TTF", 50);
    fontTitle.loadFont("samsrg.TTF", 70);
    
    for (int i=0; i<NUM; i+=20) {
        //set start position and velocity
        rb[i].pos = ofPoint(0, i);
    }
    
    iColors = 1;
}

//--------------------------------------------------------------
void testApp::update(){
	//You might want to have a heatbeat ofxOscSender here
	//sending every 60 frames or so.
	
	// hide old messages
	for( int i=0; i<NUM_MSG_STRINGS; i++ ){
		if( timers[i] < ofGetElapsedTimef() )
			msg_strings[i] = "";
	}
    
	// check for waiting messages
	while( receiver.hasWaitingMessages() ){
		// get the next message
		ofxOscMessage m;
		receiver.getNextMessage( &m );
        
		// check for mouse moved message
		if( m.getAddress() == "/quat/x" ){
			// both the arguments are int32's
			q[1] = m.getArgAsFloat(0);
		}
        else if( m.getAddress() == "/quat/y" ){
			// both the arguments are int32's
			q[2] = m.getArgAsFloat(0);
		}
        else if( m.getAddress() == "/quat/z" ){
			// both the arguments are int32's
			q[3] = m.getArgAsFloat(0);
		}
        else if( m.getAddress() == "/quat/w" ){
			// both the arguments are int32's
			q[0] = m.getArgAsFloat(0);
		}
		else{
			// unrecognized message: display on the bottom of the screen
			string msg_string;
			msg_string = m.getAddress();
			msg_string += ": ";
			for( int i=0; i<m.getNumArgs(); i++ ){
				// get the argument type
				msg_string += m.getArgTypeName( i );
				msg_string += ":";
				// display the argument - make sure we get the right type
				if( m.getArgType( i ) == OFXOSC_TYPE_INT32 )
					msg_string += ofToString( m.getArgAsInt32( i ) );
				else if( m.getArgType( i ) == OFXOSC_TYPE_FLOAT )
					msg_string += ofToString( m.getArgAsFloat( i ) );
				else if( m.getArgType( i ) == OFXOSC_TYPE_STRING )
					msg_string += m.getArgAsString( i );
				else
					msg_string += "unknown";
			}
			// add to the list of strings to display
			msg_strings[current_msg_string] = msg_string;
			timers[current_msg_string] = ofGetElapsedTimef() + 5.0f;
			current_msg_string = ( current_msg_string + 1 ) % NUM_MSG_STRINGS;
			// clear the next line
			msg_strings[current_msg_string] = "";
		}
	}
    
    quat.set(q[1], q[2], q[3], q[0]);
    
    
    for (int i=0; i<NUM; i+=20) {
        //gravity
        rb[i].vel.y = rb[i].vel.y + .1;
        
        //friction
        rb[i].vel *= .9999;
        
        //update pos
        rb[i].pos += 1;
        
        if (rb[i].pos.y > ofGetHeight()+10) {
            rb[i].pos.y = 0;
        }
    }
    
    iColors++;
    if (iColors > 254) {
        iColors = 1;
    }
    
    
}

//--------------------------------------------------------------
void testApp::draw(){
    
    ofPushMatrix();
    ofTranslate(ofGetWidth()/2-40, -160, 60);
    ofRotateZ(45);
    
    if (iSteps != 7) {
        if (q[1] > 0.30f || q[1] < -0.30f) {
            ofBackground(0, 155, 0);
            
            for (int i=0; i<NUM; i+=20) {
                ofSetColor(0, 255, 0);
                ofRect(0, rb[i].pos.y, ofGetWidth()*2.5, 10);
            }
        }
        else {
            ofBackground(155, 0, 0);
            
            for (int i=0; i<NUM; i+=20) {
                ofSetColor(255, 0, 0);
                ofRect(0, rb[i].pos.y, ofGetWidth()*2.5, 10);
            }
        }
    }
    else {
        ofBackground(ofColor::fromHsb(iColors, 255, 155));
        
        for (int i=0; i<NUM; i+=20) {
            ofSetColor(ofColor::fromHsb(iColors, 255, 255));
            ofRect(0, rb[i].pos.y, ofGetWidth()*2.5, 10);
        }
    }
    
    ofPopMatrix();
    
    
    if (iSteps > 0) {
        ofPushMatrix();
        ofTranslate(ofGetWidth()/2, ofGetHeight()/2, -200);
        ofRotateZ(q[1] * -100);
        ofSetColor(255, 255, 255);
        ofSetRectMode(OF_RECTMODE_CENTER);
        ofEnableAlphaBlending();
        imgShoe.draw(0, 0);
        ofDisableAlphaBlending();
        ofSetRectMode(OF_RECTMODE_CORNER);
        ofPopMatrix();
    }
    else {
        ofSetColor(255, 255, 255);
        ofRect(0, 0, 320, 97);
        ofSetRectMode(OF_RECTMODE_CENTER);
        imgLogo.draw(ofGetWidth()/2, 48.5, 280, 93);
        ofSetRectMode(OF_RECTMODE_CORNER);
    }
    
    switch (iSteps) {
        case 0:
            ofSetColor(255);
            fontTitle.drawString("\nMOON\nWALK", 20, 95);
            fontTitle.drawString("\nALL\nSTAR", 20, 310);
            ofDrawBitmapString("touch anywhere to begin", 20, ofGetHeight()-30);
            break;
            
        case 1:
            ofSetColor(255);
            font.drawString("STEP 1\nPUT\nYOUR\n\n\nSIDE BY\nSIDE", 20, 64);
            ofDrawBitmapString("touch anywhere to continue", 20, ofGetHeight()-30);
            break;
            
        case 2:
            ofSetColor(255);
            font.drawString("STEP 2\nSLIDE\nLEFT\n\n\nBACK", 20, 64);
            ofDrawBitmapString("touch anywhere to continue", 20, ofGetHeight()-30);
            break;
            
        case 3:
            ofSetColor(255);
            font.drawString("STEP 3\nANGLE\nLEFT\n\n\n45 DEG.", 20, 64);
            ofDrawBitmapString("touch anywhere to continue", 20, ofGetHeight()-30);
            break;
            
        case 4:
            ofSetColor(255);
            font.drawString("STEP 4\nSLIDE\nRIGHT\n\n\nBACK\nAND...", 20, 64);
            ofDrawBitmapString("touch anywhere to continue", 20, ofGetHeight()-30);
            break;
            
        case 5:
            ofSetColor(255);
            font.drawString("STEP 5\nSNAP\nLEFT\n\n\nDOWN", 20, 64);
            ofDrawBitmapString("touch anywhere to continue", 20, ofGetHeight()-30);
            break;
            
        case 6:
            ofSetColor(255);
            font.drawString("STEP 6\nANGLE\nRIGHT\n\n\n45 DEG.\nREPEAT!", 20, 64);
            ofDrawBitmapString("touch anywhere to continue", 20, ofGetHeight()-30);
            break;
            
        case 7:
            ofSetColor(255);
            font.drawString("SUCCESS !!!\nYOU'RE\nAN\n\n\nALL\nSTAR!", 20, 64);
            ofDrawBitmapString("touch anywhere to continue", 20, ofGetHeight()-30);
            break;
            
        default:
            break;
    }
}

//--------------------------------------------------------------
void testApp::exit(){
    
}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs &touch){
    
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs &touch){
    
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs &touch){
    
    if (touch.y < ofGetHeight()/2+ofGetHeight()/4) {
        iSteps++;
        
        if (iSteps > 6) {
            iSteps = 2;
        }
    }
    else {
        if (iSteps < 7) {
            iSteps = 7;
        }
        else {
            iSteps = 0;
        }
    }
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs &touch){
    
}

//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void testApp::lostFocus(){
    
}

//--------------------------------------------------------------
void testApp::gotFocus(){
    
}

//--------------------------------------------------------------
void testApp::gotMemoryWarning(){
    
}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation){
    
}
