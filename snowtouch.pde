/*
 Snowtouch.pde
 Copyright (c) 2014-2016 Kitronyx http://www.kitronyx.com
 GPL V3.0
*/

import processing.serial.*; // import the Processing serial library

Serial a_port;
String comPort;
int baudRate;
String PORT = "auto";
int[] data;
int[] baseline;
boolean is_serial_read = false;
boolean printDebugInfo = true;
float zscale = 1; // control z axis scale of graph

void setup()
{
    data = new int[12];
    baseline = new int[12];
    for (int i = 0; i < 12; i++)
    {
        data[i] = 0;
        baseline[i] = 0;
    }
    
    // initialize screen    
    size(1024, 768, P3D);
    if (frame != null)
    {
        frame.setResizable(true);
    }
    
    // initialize serial communication.
    // if no device is found, random data is generated and shown. 
    if (Serial.list().length == 0) // no device.
    {
        comPort = "Not Found";
    }
    else
    {
        if (PORT == "auto") comPort = Serial.list()[0];
        else comPort = PORT;
        baudRate = 115200;
        println(comPort);
        a_port = new Serial(this, comPort, baudRate, 'N', 8, 1);
    }
    
    // initial baseline
    getData();
    for (int i = 0; i < 12; i++) baseline[i] = data[i];
}

void draw()
{
    if (getData() == false) return;
    
    // do not draw when data is cominig.
    if (is_serial_read == true) return;
    
    background(255);
    
    int nsensor = 12;
    for (int i = 0; i < 12; i++)
    {
        //float data_reverse = data[i] - baseline[i];
        float horizontal_step = float(width) / float(2*nsensor+1);
        float rect_a = (2*i+1)*horizontal_step;
        float rect_b = height - 10;
        float rect_w = horizontal_step;
        float rect_h = -(-data[i]+baseline[i])*zscale;
        
        fill(255, 0, 0);
        noStroke();
        rect(rect_a, rect_b, rect_w, rect_h);
    }
    
    
}


// data acquisition
// originally, this function was serialEvent() but changed to be polling function
// since serial interrupt is not catched sometimes.
// it returns true if data acquisition is successfull and false if not.
//void serialEvent(Serial a_port)
boolean getData()
{
    // lock buffer.
    is_serial_read = true;

    // read the serial buffer:
    a_port.write("A");    
    String myString = a_port.readStringUntil('\n');
    if (myString == null) return false;
    
    // if you got any bytes other than the linefeed:
    myString = trim(myString);

    // split the string at the commas
    // and convert the sections into integers:
    int sensors[] = int(split(myString, ','));
    
    // copy sensor data to variables for gui
    // preprocessing (filtering) is done here.
    for (int i = 0; i < sensors.length; i++) data[i] = sensors[i];
    
    
    // debug print
    if (printDebugInfo == true)
    {
        print("SENSOR: ");
        
        for (int i = 0; i < data.length; i++)
        {
            print(data[i]);
            print(",");
        }
        println("");
    }
        
    // unlock buffer
    is_serial_read = false;
    
    return true;
}


void keyPressed()
{
    if (key == 'b')
    {
        for (int i = 0; i < 12; i++) baseline[i] = data[i];
    }
    
    if (key == CODED)
    {
        if (keyCode == UP) zscale++;
        if (keyCode == DOWN)
        {
            zscale--;
            if (zscale < 1) zscale = 1;
        }
    }
}
