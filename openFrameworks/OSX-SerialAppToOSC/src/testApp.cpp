//
//      MOON WALK ALL STAR
//      Purpose of this app is to capture data from an Arduino
//      and then send this data via OSC to an iPhone app
//
//      Developed by Jason Walters/BBDO
//      Copyright 2013
//
//      Last revision by Jason Walters on June 17th, 2013
//      Compatible with openFrameworks 0074
//
///////////////////////////////////////////////////////////////

#include "testApp.h"

int serialCount = 0;             // current packet byte position
int aligned = 0;
int interval = 0;
unsigned char serialPacket[14];  // InvenSense serial packet
float q[4];
int ch;
int alignVal = 0;

//--------------------------------------------------------------
void testApp::setup(){
	ofSetVerticalSync(true);
	
	ofSetLogLevel(OF_LOG_VERBOSE);
	
	serial.listDevices();
	vector <ofSerialDeviceInfo> deviceList = serial.getDeviceList();
	// this should be set to whatever com port your serial device is connected to.
	// (ie, COM4 on a pc, /dev/tty.... on linux, /dev/tty... on a mac)
	// arduino users check in arduino app....
	int baud = 115200;
	serial.setup(0, baud); //open the first device
    
    // open an outgoing connection to HOST:PORT
	sender.setup(HOST, PORT);
    
    font.loadFont("DIN.otf", 24);       // load our font
    imgShoe.loadImage("converse.png");  // load our shoe image
}

//--------------------------------------------------------------
void testApp::update(){
    
    interval = ofGetElapsedTimeMillis();
    
    while (serial.available() > 0) {
        int ch = serial.readByte();
        printf("%c", (char)ch);
        if (aligned < alignVal) {
            // make sure we are properly aligned on a 14-byte packet
            if (serialCount == 0) {
                if (ch == '$') aligned++; else aligned = 0;
            } else if (serialCount == 1) {
                if (ch == 2) aligned++; else aligned = 0;
            } else if (serialCount == 12) {
                if (ch == '\r') aligned++; else aligned = 0;
            } else if (serialCount == 13) {
                if (ch == '\n') aligned++; else aligned = 0;
            }
            serialCount++;
            if (serialCount == 14) serialCount = 0;
        } else {
            if (serialCount > 0 || ch == '$') {
                serialPacket[serialCount++] = (char)ch;
                if (serialCount == 14) {
                    serialCount = 0; // restart packet byte position
                    
                    // get quaternion from data packet
                    q[0] = ((serialPacket[2] << 8) | serialPacket[3]) / 16384.0f;
                    q[1] = ((serialPacket[4] << 8) | serialPacket[5]) / 16384.0f;
                    q[2] = ((serialPacket[6] << 8) | serialPacket[7]) / 16384.0f;
                    q[3] = ((serialPacket[8] << 8) | serialPacket[9]) / 16384.0f;
                    for (int i = 0; i < 4; i++){
                        if (q[i] >= 2) q[i] = -4 + q[i];
                    }
                    
                    // set our quaternion to new data
                    quat.set(q[1], q[2], q[3], q[0]);
                    
                    // send our OSC data
                    ofxOscMessage quatX;
                    quatX.setAddress("/quat/x");
                    quatX.addFloatArg(q[1]);
                    sender.sendMessage(quatX);
                    
                    ofxOscMessage quatY;
                    quatY.setAddress("/quat/y");
                    quatY.addFloatArg(q[2]);
                    sender.sendMessage(quatY);
                    
                    ofxOscMessage quatZ;
                    quatZ.setAddress("/quat/z");
                    quatZ.addFloatArg(q[3]);
                    sender.sendMessage(quatZ);
                    
                    ofxOscMessage quatW;
                    quatW.setAddress("/quat/w");
                    quatW.addFloatArg(q[0]);
                    sender.sendMessage(quatW);
                }
            }
        }
    }
}

//--------------------------------------------------------------
void testApp::draw(){
    
    // angle is greater than 30 or less then -30
    // change background to green
    if (q[1] > 0.30f || q[1] < -0.30f) {
        ofBackground(0, 255, 0);
    }
    else {
        // else keep background red
        ofBackground(255, 0, 0);
    }
    
    if (ofGetElapsedTimeMillis() - interval > 1000) {
        // resend single character to trigger DMP init/start
        // in case the MPU is halted/reset while applet is running
        serial.writeByte('r');
        interval = ofGetElapsedTimeMillis();
    }
    
    // draw shoe graphic
    glPushMatrix();
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glTranslatef(ofGetWidth()/2, ofGetHeight()/2, 200);
    ofRotateZ(q[1] * -100);
    ofSetColor(255, 255, 255);
    ofSetRectMode(OF_RECTMODE_CENTER);
    imgShoe.draw(0, 0);
    ofSetRectMode(OF_RECTMODE_CORNER);
    glPopMatrix();
    
    // draw data messages
    ofSetColor(255,255,255);
	string msg;
    msg += "quat x == " + ofToString(q[1]) + "\n";
    msg += "quat y == " + ofToString(q[2]) + "\n";
    msg += "quat z == " + ofToString(q[3]) + "\n";
    msg += "quat w == " + ofToString(q[0]) + "\n";
	font.drawString(msg, 50, 100);
}

//--------------------------------------------------------------
void testApp::keyPressed  (int key){
    switch (key) {
        case ' ':
            serial.writeByte('r');
            break;
    }
	
}

//--------------------------------------------------------------
void testApp::keyReleased(int key){
	
}

//--------------------------------------------------------------
void testApp::mouseMoved(int x, int y){
	
}

//--------------------------------------------------------------
void testApp::mouseDragged(int x, int y, int button){
	
}

//--------------------------------------------------------------
void testApp::mousePressed(int x, int y, int button){

}

//--------------------------------------------------------------
void testApp::mouseReleased(int x, int y, int button){
	
}

//--------------------------------------------------------------
void testApp::windowResized(int w, int h){
	
}

//--------------------------------------------------------------
void testApp::gotMessage(ofMessage msg){
	
}

//--------------------------------------------------------------
void testApp::dragEvent(ofDragInfo dragInfo){
	
}

