int NUM_BOXES = 20;

int datapin  = 3; // DI
int latchpin = 4; // LI
int enablepin = 5; // EI
int clockpin = 6; // CI
unsigned long SB_CommandPacket;

int SB_CommandMode;
int SB_BlueCommand;
int SB_RedCommand;
int SB_GreenCommand;

int l[10][20] = {   {1023, 0, 0, 1023, 1023, 0, 0, 1023, 1023, 1023, 1023, 1023, 1023, 0, 0, 1023, 1023, 0, 0, 1023}, // H
                          {1023, 1023, 1023, 1023, 0, 0, 0, 1023, 0, 1023, 1023, 1023, 0, 0, 0, 1023, 1023, 1023, 1023, 1023}, // E                 
                          {1023, 1023, 1023, 1023, 0, 0, 0, 1023, 0, 0, 0, 1023, 0, 0, 0, 1023, 0, 0, 0, 1023}, // L
                          {1023, 1023, 1023, 1023, 0, 0, 0, 1023, 0, 0, 0, 1023, 0, 0, 0, 1023, 0, 0, 0, 1023}, // L
                          {0, 0, 0, 0, 0, 0, 0, 0, 1023, 1023, 1023, 1023, 0, 0, 0, 0, 0, 0, 0, 0}, // -
                          {1023, 1023, 1023, 1023, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1023, 1023, 1023, 1023}, // O
                          {1023, 1023, 1023, 1023, 0, 0, 0, 0, 1023, 0, 0, 0, 0, 0, 0, 0, 1023, 1023, 1023, 1023}, // 0 animate
                          {1023, 1023, 1023, 1023, 0, 0, 0, 0, 0, 1023, 0, 0, 0, 0, 0, 0, 1023, 1023, 1023, 1023}, // 0 animate
                          {1023, 1023, 1023, 1023, 0, 0, 0, 0, 0, 0, 1023, 0, 0, 0, 0, 0, 1023, 1023, 1023, 1023}, // 0 animate
                          {1023, 1023, 1023, 1023, 0, 0, 0, 0, 0, 0, 0, 1023, 0, 0, 0, 0, 1023, 1023, 1023, 1023}}; // 0 animate
int cl = 0;

void setup() 
{
   setupPins();
}

/* ShiftBrite setup
_________________________________________________________________ */

void setupPins()
{
   pinMode(datapin, OUTPUT);
   pinMode(latchpin, OUTPUT);
   pinMode(enablepin, OUTPUT);
   pinMode(clockpin, OUTPUT);

   digitalWrite(latchpin, LOW);
   digitalWrite(enablepin, LOW);
}

/* Send packet
_________________________________________________________________ */

void SB_SendPacket() 
{
   SB_CommandPacket = SB_CommandMode & B11;
   SB_CommandPacket = (SB_CommandPacket << 10)  | (SB_BlueCommand & 1023);
   SB_CommandPacket = (SB_CommandPacket << 10)  | (SB_RedCommand & 1023);
   SB_CommandPacket = (SB_CommandPacket << 10)  | (SB_GreenCommand & 1023);

   shiftOut(datapin, clockpin, MSBFIRST, SB_CommandPacket >> 24);
   shiftOut(datapin, clockpin, MSBFIRST, SB_CommandPacket >> 16);
   shiftOut(datapin, clockpin, MSBFIRST, SB_CommandPacket >> 8);
   shiftOut(datapin, clockpin, MSBFIRST, SB_CommandPacket);

   //delay(1); // adjustment may be necessary depending on chain length
   //digitalWrite(latchpin,HIGH); // latch data into registers
   //delay(1); // adjustment may be necessary depending on chain length
   //digitalWrite(latchpin,LOW);
}

void loop() 
{
   for(int i = 0; i < NUM_BOXES; i++)
   {
      SB_CommandMode = B01; // Write to current control registers
      SB_RedCommand = 127; // Full current
      SB_GreenCommand = 127; // Full current
      SB_BlueCommand = 127; // Full current
      SB_SendPacket();
   }
  
   delayMicroseconds(15);
   digitalWrite(latchpin, HIGH);
   delayMicroseconds(15);
   digitalWrite(latchpin, LOW);
   
   for(int i = 0; i < NUM_BOXES; i++)
   {
      SB_CommandMode = B00; // Write to PWM control registers
      SB_RedCommand = l[cl][i]; // Minimum red
      SB_GreenCommand = 0; // Maximum green
      SB_BlueCommand = 0; // Minimum blue
      SB_SendPacket();
   }
   
   delayMicroseconds(15);
   digitalWrite(latchpin,HIGH);
   delayMicroseconds(15);
   digitalWrite(latchpin,LOW);
   
   delay(500);
   
   for(int i = 0; i < NUM_BOXES; i++)
   {
      SB_CommandMode = B00; // Write to PWM control registers
      SB_RedCommand = 0; // Minimum red
      SB_GreenCommand = 0; // Maximum green
      SB_BlueCommand = 0; // Minimum blue
      SB_SendPacket();
   }
   
   delayMicroseconds(15);
   digitalWrite(latchpin,HIGH);
   delayMicroseconds(15);
   digitalWrite(latchpin,LOW);

   cl++;
  
   if(cl == 10)
   {
     cl = 0; 
   }
   
   delay(500);
}
