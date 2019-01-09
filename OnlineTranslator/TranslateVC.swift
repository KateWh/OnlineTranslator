//
//  ViewController.swift
//  OnlineTranslator
//
//  Created by vitket team on 12/19/18.
//  Copyright © 2018 vitket team. All rights reserved.
//

import UIKit

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

// temlate to JSONdecode fetching data
struct TranslateResult: Codable {
    var code: Int
    var lang: String
    var text: [String]
}

class TranslateVC: UIViewController, HistoryTVDelegate {
    
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
    var historyStrArray = [String]()
    var delegatedHistory = [String]()
    var titleText = ""
    var timer = Timer()
    var counter = 1
    var titleString = "    Translate    "
    var countTranslations = 0
    var date = 0

    override func viewWillAppear(_ animated: Bool) {
        // navigationBar is hidden
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if historyStorage.timerIsTrue {
            timerSave.setTitle(prepareToView(), for: UIControl.State.normal)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        historyStorage.saveCountTranslate(countTranslate: countTranslations)
        historyStorage.saveDate(date: date)
    }
    
    // makes a string to display from the data in the database
    func prepareToView() -> String {
        _ = historyStorage.getDate()
        let translates = historyStorage.getCountTranslate()
        return "6(\(translates))"
    }

    // arrow button to translate
    @IBAction func vectorButton(_ sender: UIButton) {
        if rotateFlag {
            // rotate arrow back on 180°
            UIView.animate(withDuration: 0.4, delay: 0, options: UIView.AnimationOptions.curveEaseIn, animations: { () -> Void in
                self.vectorOutlet.transform = CGAffineTransform(rotationAngle: .pi/1)
            }, completion: nil)
            // when arrow rotated — rotateFlag and languages is changed
            rotateFlag = false
            fromLanguage = "en"
            toLanguage = "ru"
            // changed input text to output text, and vise versa, like  ( A -> B ,  B -> A )
            let saveInputText = inputTextField.text
            inputTextField.text = outputTextField.text
            outputTextField.text = saveInputText
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
            let saveInputText = inputTextField.text
            inputTextField.text = outputTextField.text
            outputTextField.text = saveInputText
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
        // remove whitespaces and newLine symbols from trailing and ... of the input string
        let inputText = inputTextField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if inputText != "" {
            // start timer to print on RED button progress
            self.timer = Timer.scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(self.setTitle), userInfo: nil, repeats: true)
        }
        // clear output field
        outputTextField.text = ""
        // do request to server
        requestResponseFunc(input: inputText)
        // read data from local storage and check input with this data on coincidence
        historyStrArray = historyStorage.retrieveData(lang: fromLanguage)
        for historyWord in historyStrArray {
            guard historyWord != inputText else { return }
        }
        // write data to local storage
        if inputText != "" {
            historyStorage.createData(from: inputText, lang: fromLanguage)
        }
    }
    
    // fetch EN history
    func fetchEnHistory() -> [String] {
        historyStrArray = historyStorage.retrieveData(lang: "en")
        return historyStrArray
    }
    
    // fetch RU history
    func fetchRuHistory() -> [String] {
        historyStrArray = historyStorage.retrieveData(lang: "ru")
        return historyStrArray
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
                    self.countTranslations += 1
                    self.timerSave.setTitle("6(\(self.countTranslations))", for: UIControl.State.normal)
                }
                // stop timer and update counter for #selector of timer
                self.timer.invalidate()
                self.counter = 1
            } catch let error {
                print(error)
            }
        }.resume()
        
    }
    
    // "Russian" button
    @IBAction func ruButton(_ sender: RoundButton) {
        delegatedHistory = fetchRuHistory()
        titleText = "История"
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "historySegue", sender: self)
        }
    }
    
    // "English" button
    @IBAction func enButton(_ sender: RoundButton) {
        delegatedHistory = fetchEnHistory()
        titleText = "History"
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "historySegue", sender: self)
        }
    }
    
    // input again to translate
    @IBAction func tryAgainButton(_ sender: RoundButton) {
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
