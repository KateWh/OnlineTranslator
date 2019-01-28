//
//  ViewController.swift
//  OnlineTranslator
//
//  Created by vitket team on 12/19/18.
//  Copyright © 2018 vitket team. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import AudioToolbox

// new class for display "Round Button" menu in Attributes inspector, in Xcode
class RoundButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
}  // END RoundButton class

// template to JSONdecode fetching data
struct TranslateResult: Codable {
    var code: Int
    var lang: String
    var text: [String]
}

class TranslateVC: UIViewController, HistoryTVDelegateProtocol {


    @IBOutlet weak var inputTextField: UITextView!
    @IBOutlet weak var outputTextField: UITextView!
    @IBOutlet weak var vectorOutlet: UIButton!
    @IBOutlet weak var translateButtonOutlet: RoundButton!
    @IBOutlet weak var timerSave: UIButton!
    // instanse HistoryStorage class
    private var historyStorage = HistoryStorage()
    
    var fromLanguage = "ru"
    var toLanguage = "en"
    var rotateFlag = true
    var dataArray = [HasFavorite(value: "", favoriteFlag: false)]
    var delegatedLang = ""
    var delegatedBookmarks = [""]
    var titleText = ""
    var timer = Timer()
    var counter = 1
    var titleString = "    Translate    "
    var countTranslations: Int? = nil
    var date: Int? = nil
    var myDate = Date(timeIntervalSinceNow: 7200)
    var countDate = 0

    override func viewWillAppear(_ animated: Bool) {
        // navigationBar is hidden
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.setToolbarHidden(true, animated: false)
        let countTranslate = historyStorage.getCountTranslate()
        countTranslations = countTranslate
        timerSave.setTitle(prepareToView(), for: .normal)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.timer.invalidate()
        self.counter = 1
        self.translateButtonOutlet.setTitle("    Translate    ", for: .normal)
        historyStorage.saveCountTranslate(countTranslate: countTranslations!)
    }
 
    // makes a string to display from the data in the database
    func prepareToView() -> String {
        let urlToDocumentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        //installDate is NSDate of install
        let installDate = (try! FileManager.default.attributesOfItem(atPath: urlToDocumentsFolder.path)[FileAttributeKey.creationDate])
        //print("This app was installed by the user on \(String(describing: installDate))")
        print("This is date now: \(myDate)")
        var result = 6
        let calendar = Calendar.current
        let month = calendar.component(.month, from: myDate) as Int
        let day = calendar.component(.day, from: myDate) as Int
        let monthInstall = calendar.component(.month, from: installDate as! Date) as Int
        let dayInstall = calendar.component(.day, from: installDate as! Date) as Int
        if monthInstall < month {
            
        } else if monthInstall == month {
            result -= day - dayInstall
            countDate = result
        }
        
        let translates = historyStorage.getCountTranslate()
        return "\(result)(\(translates))"
    }

    // arrow button to translate
    @IBAction func vectorButton(_ sender: UIButton) {
        AudioServicesPlayAlertSound(SystemSoundID(1104))
        if rotateFlag {
            // rotate arrow backward on 180°
            UIView.animate(withDuration: 0.4, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: { () -> Void in
                self.vectorOutlet.transform = CGAffineTransform(rotationAngle: .pi/1)
            }, completion: nil)
            // when arrow rotated — rotateFlag and languages is changed
            rotateFlag = false
            fromLanguage = "en"
            toLanguage = "ru"
            // changed input text to output text, and vise versa, like  ( A -> B ,  B -> A )
            if !outputTextField.text.isEmpty {
                let saveInputText = inputTextField.text
                inputTextField.text = outputTextField.text
                outputTextField.text = saveInputText
            }
        } else {
            // rotate arrow forward on 180°
            UIView.animate(withDuration: 0.4, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: { () -> Void in
                self.vectorOutlet.transform = CGAffineTransform(rotationAngle: .pi/0.5)
            }, completion: nil)
            // when arrow rotated — rotateFlag and languages is changed
            rotateFlag = true
            fromLanguage = "ru"
            toLanguage = "en"
            // change input text to output text, and vise versa, like  ( A -> B ,  B -> A )
            if !outputTextField.text.isEmpty {
                let saveInputText = inputTextField.text
                inputTextField.text = outputTextField.text
                outputTextField.text = saveInputText
            }
        }
    }
    
    // #selector of timer
    @objc func setTitle() {
        if counter == 1 {
            titleString = "    Translate.   "
            counter += 1
        } else if counter == 2 {
            titleString = "    Translate..  "
            counter += 1
        } else if counter == 3 {
            titleString = "    Translate... "
            counter = 0
        } else if counter == 0 {
            titleString = "    Translate    "
            counter += 1
        }
        
        // set RED button title text
            self.translateButtonOutlet.setTitle(self.titleString, for: .normal)

    }

    // do translate (RED Button)
    @IBAction func translateText(_ sender: UIButton) {
        AudioServicesPlayAlertSound(SystemSoundID(1104))
        // remove whitespaces and newLine symbols from trailing and ... of the input string
        let inputText = inputTextField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if inputText != "" {
            timer.invalidate()
            // start timer to print on RED button progress
            self.timer = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(self.setTitle), userInfo: nil, repeats: true)
        }
        // clear output field
        outputTextField.text = ""
        // do request to server
        requestResponseFunc(input: inputText)
        // read data from local storage and check input with this data on coincidence
        for historyWord in historyStorage.getHistory(lang: fromLanguage) {
            guard historyWord.value != inputText else { return }
        }
    }
    
    // request/response func declaration
    func requestResponseFunc(input: String) {
        view.endEditing(true)  // keyboard drops
        var inputText = ""
        
        // Encoding input string to URLString, requaed to request. Source: "https://web-developer.name/urlcode/"
        for stringElement in input.utf8 {
            let hex = String(stringElement, radix: 16)
            // check "\n"
            if hex != "a" {
                inputText += "%" + hex
            }
        }

        // link to send request
        let link = "https://translate.yandex.net/api/v1.5/tr.json/translate?key=trnsl.1.1.20181217T180034Z.14e33cb2663c2226.75d7d1ef7f4b12ca2793c54ea9ca324eec679e48&text=\(inputText)&lang=\(fromLanguage)-\(toLanguage)"

        guard let url = URL(string: link) else { return }
        
        // request
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { return }
            
            do {
                let translate = try JSONDecoder().decode(TranslateResult.self, from: data)
                DispatchQueue.main.async {
                    self.translateButtonOutlet.setTitle("    Translate    ", for: .normal)
                    self.outputTextField.text = "\(translate.text[0])"
                    // increment count translating and display it on the button
                    self.countTranslations! += 1
                    self.timerSave.setTitle("\(String(describing: self.countDate))(\(self.countTranslations!))", for: UIControl.State.normal)
                }
                // save history
                // write data to local storage
                if inputText != "" {
                    self.historyStorage.createData(from: self.inputTextField.text, at: self.fromLanguage)
                }

                // stop timer and update counter for #selector of timer
                self.timer.invalidate()
                self.counter = 1
            } catch let error {
                print(error)
            }
        }.resume()
        
    }
    
    func deleteHistory(at language: String) -> Int {
        return historyStorage.deleteHistory(at: language)
    }
    
    func deleteBookmarks() {
        return historyStorage.deleteBookmarks()
    }
    
    // "Russian" button
    @IBAction func ruButton(_ sender: RoundButton) {
        AudioServicesPlayAlertSound(SystemSoundID(1104))
        dataArray = historyStorage.getHistory(lang: "ru")
        titleText = "История"
        delegatedLang = "ru"
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "historySegue", sender: self)
        }
    }
    
    // "English" button
    @IBAction func enButton(_ sender: RoundButton) {
        AudioServicesPlayAlertSound(SystemSoundID(1104))
        dataArray = historyStorage.getHistory(lang: "en")
        titleText = "History"
        delegatedLang = "en"
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "historySegue", sender: self)
        }
    }
    
    // "Bookmarks" button
    @IBAction func bookmarksButton(_ sender: RoundButton) {
        AudioServicesPlayAlertSound(SystemSoundID(1104))
        self.dataArray = historyStorage.getBookmarks()
        titleText = "Bookmarks"
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "historySegue", sender: self)
        }
    }
    
    // input again to translate
    @IBAction func tryAgainButton(_ sender: RoundButton) {
        AudioServicesPlayAlertSound(SystemSoundID(1104))
        // stop timer
        self.timer.invalidate()
        self.counter = 1
        DispatchQueue.main.async {
            self.translateButtonOutlet.setTitle("    Translate    ", for: .normal)
        }
        inputTextField.text = ""
        outputTextField.text = ""
        // cursor appear
        inputTextField.select(sender)
    }
     
    // segue to TableView
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as? HistoryTableViewController
        destinationVC!.delegate = self
    }
    
}
