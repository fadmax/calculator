//
//  ViewController.swift
//  Calculator2
//
//  Created by Максим Фадеев on 20.06.15.
//  Copyright (c) 2015 Максим Фадеев. All rights reserved.
//

import UIKit
// Класс Контроллера
class ViewController: UIViewController {
    
    
    // Объявление переменной типа Bool для отслеживания того, находится ли пользователь в процессе печатания числа и инициализация ее со значением false
    var userIsInTheMiddleOfTupingANumber: Bool = false

    // Объявление переменной со ссылкой на объект Вида (UILabe). В данном случае он представляет собой дисплей калькулятора. Для того, чтобы считывать значение с дисплея и отображать на нем набираемое число и результат
    @IBOutlet weak var calcDisplay: UILabel!
    
    @IBOutlet weak var historyDisplay: UILabel!

    
    // Создание переменной типа CalculatorBrain, создание и присвоение ей нового объекта класса CalculatorBrain для того, чтобы обеспечить взаимодействие контроллера с моделью
    var brain = CalculatorBrain()
    
    
    // Объявление функции, которая связана с Видом и вызвается в случае тапа на одну из цифровых кнопок. В качестве параметра функция принимает объект (создается ссылка на объект). В виде объекта выступает UIButton (кнопка, которая была нажата)
    // Цель функции - добавление цифры, нажатой пользователем к содержанию дисплея (если пользователь находится в процессе печати значения, то цифра добавляется к уже присутствующим на дисплее, если нет, то цифра появляется на дисплее вместо нуля
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTupingANumber {
            if (sender.currentTitle! == ".") {
                if (calcDisplay.text?.rangeOfString(".") == nil) {
                    calcDisplay.text = calcDisplay.text! + digit
                }
            } else {
                calcDisplay.text = calcDisplay.text! + digit
                //println("digit = \(digit)")
            }
        } else {
            calcDisplay.text = digit
            userIsInTheMiddleOfTupingANumber = true
        }
        
    }
    
    // Функция, которая запускается при нажатии пользователем на одну из кнопок математических операций. Она отправляет сообщение объекту CalculatorBrain и вызывает его функцию  performOperation. Так же в случае, если пользователь находится в процессе печати числа (не нажал Enter до нажатия кнопки математической операции), то запускается функция enter. После получения результата функция отображает его на дисплее калькулятора
    @IBAction func operate(sender: UIButton) {
        
        if userIsInTheMiddleOfTupingANumber {
            enter()
        }
        historyDisplay.text = historyDisplay.text! + sender.currentTitle!
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
            } else {
                displayValue = 0
            }
        } 

    }

    @IBAction func reset() {
        calcDisplay.text = "0"
        historyDisplay.text = " "
        userIsInTheMiddleOfTupingANumber = false
        brain.clearStack()
    }
    
    
    @IBAction func backspace() {
        if count(calcDisplay.text!) > 1 {
            let valueLessOneDigit = dropLast(calcDisplay.text!)
            calcDisplay.text = valueLessOneDigit
        } else {
            displayValue = 0
        }
    }
    
    // Функция добавляет текущее значение на дисплее в архив (стэк) операндов. Для того, чтобы преобразовать значение из текстового в числовое, используется вычислимая переменная displayValue
    @IBAction func enter() {
        userIsInTheMiddleOfTupingANumber = false
        historyDisplay.text = historyDisplay.text! + "\(displayValue) "
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        } else {
            displayValue = 0
        }
    }
    
    //  Вычислимая переменная - значение вычисляется при каждом обращении к ней (как get так и set). Служит некой заменой метода в данном случае. Если запрашивается значение этой переменной, то она возвращает значение calcDisplay.text, преобразованное из текстового в чиловое. Если же задается значение этой переменной, то присваемое значение задается calcDisplay.text (выводится на дисплей калькулятора)
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(calcDisplay.text!)!.doubleValue
        }
        set {
            calcDisplay.text = "\(newValue)"
            userIsInTheMiddleOfTupingANumber = false
        }
    }
}

