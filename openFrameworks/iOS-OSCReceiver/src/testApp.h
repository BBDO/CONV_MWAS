#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "ofxOsc.h"

// listen on port 12345
#define PORT 12345
#define NUM_MSG_STRINGS 20

#define NUM 570

struct RBOX {
    ofPoint pos,vel;
};

class testApp : public ofxiPhoneApp {
    
public:
    void setup();
    void update();
    void draw();
    void exit();
    
    void touchDown(ofTouchEventArgs & touch);
    void touchMoved(ofTouchEventArgs & touch);
    void touchUp(ofTouchEventArgs & touch);
    void touchDoubleTap(ofTouchEventArgs & touch);
    void touchCancelled(ofTouchEventArgs & touch);
    
    void lostFocus();
    void gotFocus();
    void gotMemoryWarning();
    void deviceOrientationChanged(int newOrientation);
    
    ofxOscReceiver receiver;
    
    int current_msg_string;
    string msg_strings[NUM_MSG_STRINGS];
    float timers[NUM_MSG_STRINGS];
    
    ofQuaternion quat;
    float q[4];
    
    void drawCylinder(float topRadius, float bottomRadius, float tall, int sides);
    
    ofImage imgShoe;
    ofImage imgLogo;
    
    int iSteps;
    
    ofTrueTypeFont font;
    ofTrueTypeFont fontTitle;
    
    RBOX rb[NUM];
    
    int iColors;
};

