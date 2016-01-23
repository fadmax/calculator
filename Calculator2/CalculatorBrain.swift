//
//  CalculatorBrain.swift
//  Calculator2
//
//  Created by Максим Фадеев on 07.07.15.
//  Copyright (c) 2015 Максим Фадеев. All rights reserved.
//

// Модель
import Foundation

// Класс, который осуществляет операции с числами
class CalculatorBrain {
    
    //  Объявление структуры Op, которая будет хранить в себе либо цифру (операнд) либо один из двух типов возможных операций (бинарную или одиночную, в зависимости от количества операндов, которые в ней участвуют). Такая структура нужна для того, чтобы поместить в один стек и операнды, и операторы
    //  Структура enum используется тогда, когда только один из ее атрибутов будет инициализирован в каждом случае. При этом для каждого атрибута установлены типы данных, которые могут быть в него отнесены (на которые он может ссылаться)
    //  Структура реализует протокол Printable для того, чтобы она могла отвечать за то, как она будет печататься в консоль
    private enum Op: Printable {
        
        case Operand(Double)
        case UnaryOperation(String, Double->Double)
        case BinaryOperation(String, (Double, Double)->Double)
        case Constant(String, Double)
        
        // Вычислима переменная для обеспечения протокола Printable (только get). Определаяется,что будет распечатано в каждом случае. В случае операций - это только символ операции, без самой функции
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .UnaryOperation(let symbol, _):
                    return  symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                case .Constant(_, let constant):
                    return "\(constant)"
                }
            }
        }
    }
    
    //  Объявление переменной архива (который будет исполнять роль стэка) для хранения ссылок на структуры типа Op и инициализация (создание) архива (пустым)
    private var opStack = [Op]()
    
    func clearStack() {
        opStack = []
    }
    
    // Объявление переменной словаря (ключ - значение) и инициализация пустого словаря с указанием того, что ключи будут типа String, а значения - типа Op.
    private var knownOps = [String:Op]()
    
    // Определение конструктора класса
    init() {
        // Функция, которой в качестве аргумента передают структуру типа Op (содержащую функцию) и она при помощи вычислимой переменной description получает ключ типа стринг и задает этому ключу значение в виде струкруны Op (той самой, что была передана функции в качестве аргумента)
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        //  Создание элементов словаря будет осуществляться в ходе инициализации объекта класса CalculatorBrain
        //  Ключу в виде текстового обозначения оператора присваивается значение в виде структуры типа Op с сохранением в ней этого же текстового значения оператора, а так же функции, которую обозначает этот оператор.
        // При помощи функции learnOp в Словарь knownOps добавляется новая пара ключ - структура Op
        learnOp(Op.BinaryOperation("×", *))
        knownOps["÷"] = Op.BinaryOperation("÷") {$1 / $0}
        knownOps["+"] = Op.BinaryOperation("+", +)
        knownOps["−"] = Op.BinaryOperation("−") {$1 - $0}
        knownOps["√"] = Op.UnaryOperation("√", sqrt)
        knownOps["∏"] = Op.Constant("∏", M_PI)
        knownOps["sin"] = Op.UnaryOperation("√", sin)
        knownOps["cos"] = Op.UnaryOperation("√", cos)
    }
    
    // Рекурсивная функция по рассчету значения стэка из структур тип Op. Функция принимает в качестве аргумента архив структур Op и возвращает результат и архив из оставшихся элементов Op. Возврат оставшихся элементов  Op нужен при рекурсивных запуках функции
    private func evaluate(ops: [Op]) -> (result: Double?, remainigOps: [Op]) {
        if !ops.isEmpty { // Проверка на то, что стэк не пустой
            var remainigOps = ops // Эта переменная нужна для того, чтобы модифицировать переданный данной функции стэк (так как аргументы по умолчанию let и не могут быть изменены
            let op = remainigOps.removeLast() // Удаляем из стэка последний элемент и присваеваем его значение переменной op
            switch op {
            case .Operand(let operand):
                return (operand, remainigOps) // Если содержимое op - операнд, то функция возвращает его значение и стэк из оставшихся структур типа Op
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainigOps) // Если содержимое op - операция с одним операндом, то используется рекурсивный вызов функции evaluate, с передачей ей в качестве аргумента архива из оставшихся Op
                if let operand = operandEvaluation.result { // Если этот рекурсивный вызов функции заканчивается успешно (проверка того, что возвращаемый результат не равняется nil),то значение результата присваевается переменной operand
                    return (operation(operand), operandEvaluation.remainigOps) // Полученный операнд, подставляется в функцию, которую содержит данная структура и результат возвращается вместе с архивом из оставшихся элементов Op
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainigOps) // Рекурсивный вызов функции с передачей ей в качестве аргумента архива из оставшихся op
                if let operand1 = op1Evaluation.result { // Если вызов функции успешен, значение ее результата присваеватся переменной
                    let op2Evaluation = evaluate(op1Evaluation.remainigOps) // Рекурсивный вызов функции с передачей ей архива оставшихся после вычисления первого оператора структур типа Op
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainigOps)
                        
                    }
                }
            case .Constant(_, let pi):
                return (pi, remainigOps)
            }
        }
        return (nil, ops)
    }
    
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    // Создание функции по добавлению операнда (поступающего из Controller) в стэк, содержащий элементы типа Op. При этом создается новый объект структуры Op с заданием ему значения атрибута Operand значением, полученным от Controller (в виде параметра этой функции)
    func pushOperand(operand:Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    // Функция, которая вызывается контроллером при нажати на одну из кнопок математических операций. Принимает в качестве параметра String с обозначением мат. операции, затем ищет совпадение в Dictionary knownOps (вытаскивает оттуда Op по ключу) и если это происходит успешно - добавляет этот Op в стэк. Далее запускается функция evaluate для расчета значения стэка
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
}