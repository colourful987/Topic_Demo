//: Advanced & Practical Enum usage in Swift下集

import UIKit


/*
    swift中的CustomStringConvertible协议需要我们为类添加一个说明
    即一个description:String类型的可读变量
    声明如下：
    protocol CustomStringConvertible {
    var description: String { get }
    }
*/

// 继续上文中的Trade例子
// 让Trade类遵循该协议 为此我们需要添加description计算变量
// 它是通过枚举值来生成一个说明
enum Trade: CustomStringConvertible {
    case Buy, Sell
    var description: String {
        switch self {
        case Buy: return "We're buying something"
        case Sell: return "We're selling something"
        }
    }
}

let action = Trade.Buy
print("this action is \(action)")


//: 我们以一个账号管理系统加深枚举遵循协议使用

// 首先定义一个协议
// 条件有三：剩余资金(可读变量)、资金转入和资金移除两个方法
protocol AccountCompatible {
    var remainingFunds: Int { get }
    mutating func addFunds(amount: Int) throws
    mutating func removeFunds(amount: Int) throws
}

// 声明一个Account类
enum Account {
    case Empty
    case Funds(remaining: Int)
    
    enum Error: ErrorType {
        case Overdraft(amount: Int)
    }
    
    var remainingFunds: Int {
        switch self {
        case Empty: return 0
        case Funds(let remaining): return remaining
        }
    }
}

// 我们不想把遵循协议的内容也放到Account主题中实现，为此采用extension来实现。
extension Account: AccountCompatible {
    
    mutating func addFunds(amount: Int) throws {
        var newAmount = amount
        if case let .Funds(remaining) = self {
            newAmount += remaining
        }
        if newAmount < 0 {
            throw Error.Overdraft(amount: -newAmount)
        } else if newAmount == 0 {
            self = .Empty
        } else {
            self = .Funds(remaining: newAmount)
        }
    }
    
    mutating func removeFunds(amount: Int) throws {
        try self.addFunds(amount * -1)
    }
    
}

var account = Account.Funds(remaining: 20)
print("add: ", try? account.addFunds(10))
print ("remove 1: ", try? account.removeFunds(15))
print ("remove 2: ", try? account.removeFunds(55))


//: 枚举中使用extension分离用例声明和方法声明

// Entities枚举声明
enum Entities {
    case Soldier(x: Int, y: Int)
    case Tank(x: Int, y: Int)
    case Player(x: Int, y: Int)
}
// Entities枚举方法声明 其实是对Entities的扩展
extension Entities {
    mutating func move(dist: CGVector) {}
    mutating func attack() {}
}
// Entities遵循CustomStringConvertible协议
extension Entities: CustomStringConvertible {
    var description: String {
        switch self {
        case let .Soldier(x, y): return "\(x), \(y)"
        case let .Tank(x, y): return "\(x), \(y)"
        case let .Player(x, y): return "\(x), \(y)"
        }
    }
}


//: 枚举中的泛型

// 简单例子
enum Either<T1, T2> {
    case Left(T1)
    case Right(T2)
}
// 为泛型加上条件约束
enum Bag<T: SequenceType where T.Generator.Element==Equatable> {
    case Empty
    case Full(contents: T)
}

//: 枚举中的递归

// 注意case前面的关键字indirect，倘若多个case前都可以递归 那么简化写法可以是把indirect写在enum前面即可
enum FileNode {
    case File(name: String)
    indirect case Folder(name: String, files: [FileNode])
}

// 如下
indirect enum Tree<Element: Comparable> {
    case Empty
    case Node(Tree<Element>,Element,Tree<Element>)
}

//: Comparing Enums with associated values

enum Trade_3 {
    case Buy(stock: String, amount: Int)
    case Sell(stock: String, amount: Int)
}
var trade1 = Trade_3.Buy(stock:"stock1",amount:2)
var trade2 = Trade_3.Buy(stock: "stock2", amount: 3)

// 倘若我们使用if trade1 == trade2{} 进行比较 那么报错为你未实现Trade_3的类型之间的比较
// 为此我们需要实现Trade_3类型的 == 
func ==(lhs: Trade_3, rhs: Trade_3) -> Bool {
    switch (lhs, rhs) {
    case let (.Buy(stock1, amount1), .Buy(stock2, amount2))
        where stock1 == stock2 && amount1 == amount2:
        return true
    case let (.Sell(stock1, amount1), .Sell(stock2, amount2))
        where stock1 == stock2 && amount1 == amount2:
        return true
    default: return false
    }
}


//: 自定义构造方法
enum Device {
    case AppleWatch
    static func fromSlang(term: String) -> Device? {
        if term == "iWatch" {
            return .AppleWatch
        }
        return nil
    }
}

// 上面使用了static 方法实现 现在使用init?构造方法实现
enum Device_1 {
    case AppleWatch
    init?(term: String) {
        if term == "iWatch" {
            self = .AppleWatch
        }
        return nil
    }
}

// 当然我们还能这么干
enum NumberCategory {
    case Small
    case Medium
    case Big
    case Huge
    init(number n: Int) {
        if n < 10000 { self = .Small }
        else if n < 1000000 { self = .Medium }
        else if n < 100000000 { self = .Big }
        else { self = .Huge }
    }
}
let aNumber = NumberCategory(number: 100)
print(aNumber)


//: ErrorType的使用

// ErrorType是一个空协议 这样我们就能自定义错误了！！
enum DecodeError: ErrorType {
    case TypeMismatch(expected: String, actual: String)
    case MissingKey(String)
    case Custom(String)
}


// 不如来看下HTTP/REST API中错误处理
enum APIError : ErrorType {
    // Can't connect to the server (maybe offline?)
    case ConnectionError(error: NSError)
    // The server responded with a non 200 status code
    case ServerError(statusCode: Int, error: NSError)
    // We got no data (0 bytes) back from the server
    case NoDataError
    // The server response can't be converted from JSON to a Dictionary
    case JSONSerializationError(error: ErrorType)
    // The Argo decoding Failed
    case JSONMappingError(converstionError: DecodeError)
}

// 状态码使用
enum HttpError: String {
    case Code400 = "Bad Request"
    case Code401 = "Unauthorized"
    case Code402 = "Payment Required"
    case Code403 = "Forbidden"
    case Code404 = "Not Found"
}

// JSON数据转换
/* 这是作者从JSON第三方库中提取的代码
enum JSON {
    case JSONString(Swift.String)
    case JSONNumber(Double)
    case JSONObject([String : JSONValue])
    case JSONArray([JSONValue])
    case JSONBool(Bool)
    case JSONNull
}
*/

// 联系实际 我们经常会设定identifier值
enum CellType: String {
    case ButtonValueCell = "ButtonValueCell"
    case UnitEditCell = "UnitEditCell"
    case LabelCell = "LabelCell"
    case ResultLabelCell = "ResultLabelCell"
}

// 单位转换
enum Liquid: Float {
    case ml = 1.0
    case l = 1000.0
    func convert(amount amount: Float, to: Liquid) -> Float {
        if self.rawValue < to.rawValue {
            return (self.rawValue / to.rawValue) * amount
        } else {
            return (self.rawValue * to.rawValue) * amount
        }
    }
}
// Convert liters to milliliters
print (Liquid.l.convert(amount: 5, to: Liquid.ml))

// 游戏案例
enum FlyingBeast { case Dragon, Hippogriff, Gargoyle }
enum Horde { case Ork, Troll }
enum Player { case Mage, Warrior, Barbarian }
enum NPC { case Vendor, Blacksmith }
enum Element { case Tree, Fence, Stone }

protocol Hurtable {}
protocol Killable {}
protocol Flying {}
protocol Attacking {}
protocol Obstacle {}

extension FlyingBeast: Hurtable, Killable, Flying, Attacking {}
extension Horde: Hurtable, Killable, Attacking {}
extension Player: Hurtable, Obstacle {}
extension NPC: Hurtable {}
extension Element: Obstacle {}

// 以字符形式输入代码,例如实际开发中视图的背景图片
enum DetailViewImages: String {
    case Background = "bg1.png"
    case Sidebar = "sbg.png"
    case ActionButton1 = "btn1_1.png"
    case ActionButton2 = "btn2_1.png"
}

// API Endpoints
enum Instagram {
    enum Media {
        case Popular
        case Shortcode(id: String)
        case Search(lat: Float, min_timestamp: Int, lng: Float, max_timestamp: Int, distance: Int)
    }
    enum Users {
        case User(id: String)
        case Feed
        case Recent(id: String)
    }
}






