//
//  ViewController.swift
//  PlivoDemo
//
//  Created by Nikolay Petrovich on 3/14/16.
//  Copyright © 2016 Alexey K. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController, PlivoEndpointDelegate, PlivoRestDelegate, UITextFieldDelegate {

    var phone: Phone = Phone()
    var outCall: PlivoOutgoing = PlivoOutgoing()
    var incCall: PlivoIncoming = PlivoIncoming()
    
    var theUsername: NSString = ""
    var thePassword: NSString = ""
    var theAlias: NSString = ""
    var endpointId: NSString = ""
    var createEndpointIdentifier: NSString = ""
    var letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    
    @IBOutlet weak var logoView: UITextView!
    @IBOutlet weak var callStateInterface: UIView!
    @IBOutlet weak var textfieldInputSIP: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        initSetup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initSetup() {
        phone.setDelegate(self)
        
        self.logoView.text = "- Initializing app\n"
        
        theUsername = "test"
        theAlias = "test";
        
        /* string identifier for creating endpoint Plivo REST API */
        createEndpointIdentifier = "Endpoint/CREATE";
        
        let volumeView = MPVolumeView(frame: self.callStateInterface.bounds)
        self.callStateInterface.addSubview(volumeView)

    }
    
    @IBAction func createEndpoint(sender: AnyObject) {
        
        let username = NSUserDefaults.standardUserDefaults().objectForKey("username")
        let password = NSUserDefaults.standardUserDefaults().objectForKey("password")
        
        if username != nil {
            logDebug("- Logging in")
            self.phone.loginWithUsername(username as! String, andPassword: password as! String)
        } else {
            logDebug("- Creating endpoint")
            logDebug("- Generating random password")
            
            thePassword = genRandStringLength(10)
            self.phone.createEndpointWithUsername(theUsername as String, andPassword: thePassword as String, andAlias: theAlias as String)

        }
       
    }
    
    @IBAction func callWithUser(sender: AnyObject) {
        /* get destination value */
        let dest = self.textfieldInputSIP.text
        
        /* check if user already entered the destinantion number */
        if dest?.characters.count == 0 {
            logDebug("- Please enter SIP URI or Phone Number")
        }
        
        /* set extra headers */
        let extraHeaders = NSDictionary.init(objects: ["Zach", "Patkar", "1234567890"], forKeys: ["X-PH-DoctorName", "X-PH-PatientName", "X-PH-PatientPhone"])
        
        /* log it */
        let debugStr = String("- Make a call to '\(dest)'")
        logDebug(debugStr)
        
        /* make the call */
        outCall = self.phone.callWithDest(dest, andHeaders: extraHeaders as [NSObject : AnyObject])

    }
    
    @IBAction func endCall(sender: AnyObject) {
        /* log it */
        logDebug("- Hangup the call")
        
        /* hang it up */
        outCall.disconnect()
    }
    
    @IBAction func logOut(sender: AnyObject) {
        logDebug("- Logging out")
        self.phone.logout()
    }
    
    @IBAction func callAnswer(sender: AnyObject) {
        /* log it */
        logDebug("- Answering call")
        
        /* answer the call */
        if !self.incCall.isEqual(nil) {
            self.incCall.answer()
        }
        
    }
    
    @IBAction func hangUpCall(sender: AnyObject) {
        logDebug("- Hangup call")
        
        /* hangup the call */
        if !self.incCall.isEqual(nil) {
            self.incCall.hangup()
        }

    }
    
    //MARK - UserDefine Functions
    
    /**
    * Print debug log to textview in the bottom of the view screen
    */
    
    func logDebug(message: NSString) {
        
        dispatch_async(dispatch_get_main_queue(), {
            
            // DO SOMETHING ON THE MAINTHREAD
            
            /* add newline to end of the message */
            let toLog = String(format:"\(message)\n")
            
            /* insert message */
            self.logoView.insertText(toLog)
            
            /* Scroll textview */
            self.logoView.scrollRangeToVisible(NSMakeRange(self.logoView.text.characters.count, 0))
        })

    }
    
    /**
    * generate random strings
    */

    func genRandStringLength(len: Int) -> NSString {
        let randomString = NSMutableString.init(capacity: len)
        
        for index in 1...len {
            randomString.appendFormat("%C", letters.characterAtIndex((random() * index * 100) % letters.length))
        }
        
        return randomString

    }
    
    //MARK - TextField Delegate
    
    /**
    * Hide keyboard after user press 'return' key
    */
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.textfieldInputSIP {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    //MARK - CreateEndPoint Delegate
    
    /**
    * This delegate will be called when plivo REST API call succeed.
    */
    func successWithResponse(response: [NSObject : AnyObject]!, andIdentifier identifier: String!) {
        
        let cResponse = response as NSDictionary
        
        if createEndpointIdentifier.isEqualToString(identifier) {
            logDebug("- Endpoint created")
            
            /* get endpoint id and username */
            endpointId = cResponse.objectForKey("endpoint_id") as! NSString
            let generatedUsername = cResponse.objectForKey("username") as! NSString
            
            NSUserDefaults.standardUserDefaults().setObject(generatedUsername, forKey: "username")
            NSUserDefaults.standardUserDefaults().setObject(thePassword, forKey: "password")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            /* log */
            let logMsg = String("- Username = \(generatedUsername).\n- Endpoint id = \(endpointId)")
            logDebug(logMsg)
            
            /* show it above 'create and login' button */
            let msg = String("Endpoint created = sip:\(generatedUsername)@phone.plivo.com")
            logDebug(msg)
            
            /* login */
            logDebug("- Logging in")
            self.phone.loginWithUsername(generatedUsername as String, andPassword: thePassword as String)
            
        } else {
            logDebug("- Endpoint destroyed")

        }
        
    }
    
    /**
    * This delegate will be called when Plivo REST API call failed
    */
    func failureWithError(error: NSError!, andIdentifier identifier: String!) {
        NSLog("failuteWithError.identifier = \(identifier).error=\(error)")
        
        if createEndpointIdentifier.isEqualToString(identifier) {
            logDebug("- Create endpoint failed")
        } else {
            logDebug("- Delete endpoint failed")
        }
    
    }
    
    //MARK - EndPoint Delegate
    
    /**
    * This delegate gets called when registration to an endpoint is successful.
    */
    func onLogin() {
        logDebug("- Logged in")
    }
    
    /**
    * onLoginFailed delegate implementation.
    */
    func onLoginFailed() {
        logDebug("- Login failed. Please check your username and password")
    }
    
    /**
    * This delegate gets called when unregistration to an endpoint is successful.
    */
    func onLogout() {
        logDebug("- Logged out")
        logDebug("- Destroying endpoint")
//        self.phone.deleteEndpoint(endpointId as String)
    }
    
    //MARK - onOutgoingCall Delegate
    
    /**
    * onOutgoingCallAnswered delegate implementation
    */
    func onOutgoingCallAnswered(call: PlivoOutgoing!) {
        logDebug("- On outgoing call answered")
    }
    
    /**
    * onOutgoingCallHangup delegate implementation.
    */
    func onOutgoingCallHangup(call: PlivoOutgoing!) {
        logDebug("- On outgoing call hangup")
    }
    
    /**
    * onCalling delegate implementation.
    */
    func onCalling(call: PlivoOutgoing!) {
        logDebug("- On calling")
    }
    
    /**
    * onOutgoingCallRinging delegate implementation.
    */
    func onOutgoingCallRinging(call: PlivoOutgoing!) {
        logDebug("- On outgoing call ringing")
    }
  
    /**
    * onOutgoingCallrejected delegate implementation.
    */
    func onOutgoingCallRejected(call: PlivoOutgoing!) {
        logDebug("- On outgoing call rejected")
    }
    
    /**
    * onOutgoingCallInvalid delegate implementation.
    */
    func onOutgoingCallInvalid(call: PlivoOutgoing!) {
        logDebug("- On outgoing call invalid")
    }
    
    //MARK - onIncomingCall Delegate
    
    /**
    * onIncomingCall delegate implementation
    */
    func onIncomingCall(incoming: PlivoIncoming!) {
        /* log it */
        let logMsg = String(format:"- Call from \(incoming.fromContact)")
        logDebug(logMsg)
        
        /* assign incCall var */
        self.incCall = incoming
        
        /* enable answer & hangup button */

        /* print extra header */
        if incoming.extraHeaders.count > 0 {
            logDebug("- Extra headers:")
            let dic = incoming.extraHeaders as NSDictionary
            
            for (key, value) in dic {
                let keyVal = String(format:"-- \(key) => \(value)")
                logDebug(keyVal)
            }
            
        }
        
        
    }
    
    /**
    * onIncomingCallHangup delegate implementation.
    */
    func onIncomingCallHangup(incoming: PlivoIncoming!) {
        logDebug("- Incoming call ended")
    }
    
    /**
    * onIncomingCallRejected implementation.
    */
    func onIncomingCallRejected(incoming: PlivoIncoming!) {
        logDebug("- Incoming call rejected")
    }
     

}

