#include <FreqCount.h>

const int nOE = 6;
const int S0 = 8;
const int S1 = 7;
const int S2 = 9;
const int S3 = 10;

const int light_switch_pin = 13;

int sensitivity = 1; // 0x (off), 1x, 10x, 100x
int fscale = 1; // divide by: 1, 2, 10, 100
int num_measurements = 0;

boolean transmit = false;

void setup() {

    pinMode(nOE, OUTPUT);
    pinMode(S0, OUTPUT);
    pinMode(S1, OUTPUT);
    pinMode(S2, OUTPUT);
    pinMode(S3, OUTPUT);

    pinMode(light_switch_pin, OUTPUT);
  
    digitalWrite(nOE, HIGH);

    light_switch(0);
    set_sensitivity(sensitivity);
    set_scaling(fscale);
  
    Serial.begin(9600); // connect to the serial port
    delay(100);
    FreqCount.begin(1000); // gate time of 1000 ms.
}

void loop() {
  
    unsigned long f = 0;
    char cmd = '\0';
    char argbuf[4] = "xxx";
    int arg = 0;
    char p = 'x';
 
    if (Serial.available() >= 4) {
      
        cmd = Serial.read();
   
        for (int i=0; i<3; i++) {
            argbuf[i] = Serial.read();
        }
        
        arg = atoi(argbuf);
          
        switch (cmd) {
        case 't':  //arg: 000 is off, 111 is on
            transmit = true;
            digitalWrite(nOE, LOW);
            num_measurements = arg;
            break;
        case 'l':  //arg: 000 is off, 111 is on
            light_switch(arg);
            break;
        case 's':
            set_sensitivity(arg);
            break;
        case 'f':
            set_scaling(arg);
            break;
        default: // catches bad commands
            ;
        }
    }

    if (transmit == true && FreqCount.available()) {

        f = fscale*(FreqCount.read());
        Serial.print(f);
        Serial.print("\n");
        
        num_measurements--;
        if (num_measurements <= 0) {
            transmit = false;
            digitalWrite(nOE, HIGH);
            //MATLAB's fgetl doesn't see EOF correctly with serial, so send
            //an explicit indicator that there is no more data.
            Serial.print("EOT\n");
        }
        
        delay(200);
    }
}


void light_switch (int switch_state) {
  
    if (switch_state == 0)
        digitalWrite(light_switch_pin, LOW);
    else if (switch_state == 111)
        digitalWrite(light_switch_pin, HIGH);
        
    return;
}

void set_sensitivity( int s ) {

    switch( s ) {
    case 0: // power down
        sensitivity = s;
        digitalWrite(S0, LOW);
        digitalWrite(S1, LOW);
        break;
    case 1: // 1x
        sensitivity = s;
        digitalWrite(S0, HIGH);
        digitalWrite(S1, LOW);
        break;
    case 10: // 10x
        sensitivity = s;
        digitalWrite(S0, LOW);
        digitalWrite(S1, HIGH);
        break;
    case 100: // 100x
        sensitivity = s;
        digitalWrite(S0, HIGH);
        digitalWrite(S1, HIGH);
        break;
    default:
        break;
    }

    return;  
}


void set_scaling ( int fs ) {

    switch( fs ) {
    case 1: //divide by 1 (no scaling)
        fscale = fs;
        digitalWrite(S2, LOW);
        digitalWrite(S3, LOW);
        break;
    case 2: //divide by 2
        fscale = fs;
        digitalWrite(S2, HIGH);
        digitalWrite(S3, LOW);
        break;
    case 10: //divide by 10
        fscale = fs;
        digitalWrite(S2, LOW);
        digitalWrite(S3, HIGH);
        break;
    case 100: //divide by 100
        fscale = fs;
        digitalWrite(S2, HIGH);
        digitalWrite(S3, HIGH);
        break;
    default:
        break;
    }

    return;
}
