#include <FreqCount.h>

const int nOE = 6;
const int S0 = 8;
const int S1 = 7;
const int S2 = 9;
const int S3 = 10;

// The TSL230R outputs a square wave if it is told to scale it's output.
// A square wave is easier to detect.
int fscale = 2; //divide by: 1, 2, 10, 100

void setup() {

    pinMode(nOE, OUTPUT);
    pinMode(S0, OUTPUT);
    pinMode(S1, OUTPUT);
    pinMode(S2, OUTPUT);
    pinMode(S3, OUTPUT);

    digitalWrite(nOE, LOW); //output enabled
  
    // set sensitivity
    // S1 S0: L L = Power down, L H = multiply-by 1, H L = 10, H H = 100
    digitalWrite(S1, LOW);
    digitalWrite(S0, HIGH);

    // set scaling
    // S3 S2: L L = divide-by 1, L H = 2, H L = 10, H H = 100
    digitalWrite(S3, LOW);
    digitalWrite(S2, HIGH);

    Serial.begin(9600);

    // This code is only correct for a gate_time of 1 second. This is
    // an example so we're keeping it simple. If you want to use a
    // different gate time you'll have to divide by the number of
    // milliseconds per second and use floats when calculating the
    // output frequency. 1000 milliseconds == 1 second.
    FreqCount.begin(1000);
}

void loop() {
    unsigned long f = 0;

    if (FreqCount.available()) {
        // Read the counts per second multiply by fscale to get the
        // actual frequency.
        f = fscale*(FreqCount.read());
        Serial.print(f);
        Serial.print("\n");
        delay(20);
    }
}
