private var UDPHost : String = "127.0.0.1";
private var listenerPort : int = 8000;
private var broadcastPort : int = 57131;
private var oscHandler : Osc;

private var eventName : String = "";
private var eventData : String = "";
private var posX : int = 0;
private var posZ : int = 0;
private var area : int = 0;
//public var output_txt : UnityEngine.UI.Text;

public function Start ()
{	
	var udp : UDPPacketIO = GetComponent("UDPPacketIO");
	udp.init(UDPHost, broadcastPort, listenerPort);
	oscHandler = GetComponent("Osc");
	oscHandler.init(udp);
			
	//oscHandler.SetAddressHandler("/eventTest", updateText);
	oscHandler.SetAddressHandler("/positionData", positionData);
	
}
Debug.Log("Running");

function Update () {
	//output_txt.text = "Event: " + eventName + " Event data: " + eventData;
	
	var cube = GameObject.Find("trackingTarget");
	var x:int = posX;
	var z:int = posZ;
	var str:int = area;
    //cube.transform.localScale = Vector3(boxWidth,5,boxHeight);	
	cube.transform.position = new Vector3(x,35,z);
	cube.GetComponent("trackingCast").SetRange(str);    
    /*
    var global = GameObject.Find("Global");
    var boxWidth:int = posX;
    var boxHeight:int = posZ;
    var digStrength:int = area;
    */
}	
public function positionData(oscMessage : OscMessage) : void
{	
	Osc.OscMessageToString(oscMessage);
    posX = oscMessage.Values[0];
    posZ = oscMessage.Values[1];
    area = oscMessage.Values[2];
    //print(posX +" "+ posZ);
} 

/*public function updateText(oscMessage : OscMessage) : void
{	
	eventName = Osc.OscMessageToString(oscMessage);
	eventData = oscMessage.Values[0];
} */

