//: Advanced & Practical Enum usage in Swift(上集)

import UIKit




//: 定义一个基础Enum

// Defining Basic Enums - 定义Player的四个移动方向
enum Movement{
    case Left
    case Right
    case Top
    case Bottom
}

// 定义一个值为Left的枚举
let aMovement = Movement.Left

// 那么如何知道aMovement表示枚举中的哪个值呢？有如下几种方式:

// 方式一：switch匹配,缺点是代码多，显得兴师动众了！
switch aMovement{
case .Left:print("left");
default:()
}
// 这是swift2.0新加入的语法 
// 其中case .Left = aMovement 进行匹配，两个结果：成功or失败
// if打头的作用也显而易见了，if 成功 就执行语句，失败则跳过
if case .Left = aMovement {print("left");}

// 这是早前的值判断方式
if aMovement == .Left {print("left");}

//: 目前比较而言新匹配方式没有优势，不过请耐心看下去，会让你受益匪浅。

//: enum RawValue

// 定义一个枚举，其枚举值是Int类型
enum Movements:Int{
    case Left = 0
    case Right = 1
    case Top = 2
    case Bottom = 3
}

// 定义一个枚举，其枚举值是String类型
// 题外话：倘若不加后面那些字符串 那么默认关联值是？？ 答案是枚举变量名！不妨试试
enum House: String {
    case Baratheon = "Ours is the Fury"
    case Greyjoy = "We Do Not Sow"
    case Martell = "Unbowed, Unbent, Unbroken"
    case Stark = "Winter is Coming"
    case Tully = "Family, Duty, Honor"
    case Tyrell = "Growing Strong"
}
// 定义一个枚举，其枚举值是Double类型

enum Constants: Double {
    case π = 3.14159
    case e = 2.71828
    case φ = 1.61803398874
    case λ = 1.30357
}

//: 注意到枚举的枚举值都是基础类型，即Integer Floating Point String Boolean
//: 至于复杂类型 我们等等再说

// 枚举中单个用例是这么声明的  case关键字 + 用例名 + 关联值
// 那么如何取到 枚举值呢？ swift为我们提供了rawvalue这个属性
let bestHouse = House.Stark
print(bestHouse.rawValue)

// 那么问题来了，如何用rawvalue来初始化一个枚举呢？
let right = Movements(rawValue: 1)

// 注意使用rawValue来生成一个枚举的构造方法是一个可失败构造器 原因是倘若你输入一个无效的rawValue 肯定返回一个nil喽

// 有C语言开发经历的朋友都对0x000001 0x000010等表示不陌生，枚举值因此也可以这么干
enum VNodeFlags : UInt32 {
    case Delete = 0x00000001
    case Write = 0x00000002
    case Extended = 0x00000004
    case Attrib = 0x00000008
    case Link = 0x00000010
    case Rename = 0x00000020
    case Revoke = 0x00000040
    case None = 0x00000080
}


//: 枚举嵌套

// 想像游戏中角色有盗贼 武士 骑士 他们肯定有头盔(Helmet)和武器(Weapon)吧
// 我们首先为三个角色新建一个枚举，在该枚举中我们还可以定义2个三个角色独有的装备枚举
enum Character {
    // 武器
    enum Weapon {
        case Bow
        case Sword
        case Lance
        case Dagger
    }
    // 头盔
    enum Helmet {
        case Wooden
        case Iron
        case Diamond
    }
    // 三个角色
    case Thief
    case Warrior
    case Knight
}
// OK 分别定义盗贼角色、一把武器、一个头盔
let character = Character.Thief
let weapon = Character.Weapon.Bow
let helmet = Character.Helmet.Iron

// 不过这样 真心看不出武器头盔与角色之间的关联关系 
// 为此深思熟虑之后我们改动struct结构体来干
struct Character1{
    enum CharacterType {
        case Thief
        case Warrior
        case Knight
    }
    enum Weapon {
        case Bow
        case Sword
        case Lance
        case Dagger
    }
    let type: CharacterType
    let weapon: Weapon
}

let warrior = Character1(type: .Warrior, weapon: .Sword)

//: 枚举中的Assciated Value 关联值讲解

// 交易分两种: 买和卖
enum Trade {
    case Buy
    case Sell
}
// 单独声明一个函数用于处理交易，需要分别传入交易类型 股票名和交易数量 显得有点关联性不强
func trade(tradeType: Trade, stock: String, amount: Int) {}

// 关联值可以非常好的将信息绑定到枚举值中
enum Trade_1{
    case Buy(stock: String, amount: Int)
    case Sell(stock: String, amount: Int)
}
func trade_1(type: Trade_1) {}

// 前面说到新匹配方式没有优势，反驳时间到，请看下面例子
let trade = Trade_1.Buy(stock: "APPL", amount: 500)

// 当然if case Trade_1.Buy(let stock,let amount) = trade才是初始状态
// 为了简化才把let提到外面来
if case let Trade_1.Buy(stock, amount) = trade {
    print("buy \(amount) of \(stock)")
}

//: Tuples as Arguments

// 例子
let tp = (stock: "TSLA", amount: 100)
let mytrade = Trade_1.Sell(tp)

if case let Trade_1.Sell(stock, amount) = mytrade {
    print("buy \(amount) of \(stock)")
}

// 先为元组取一个别名
typealias Config = (RAM: Int, CPU: String, GPU: String)

// 传入一个配置 将其中Ram配置默认修改为32
func selectRAM(config: Config) -> Config {return (RAM: 32, CPU: config.CPU, GPU: config.GPU)}
// 传入一个配置 将其中CPU配置默认修改为3.2GHZ
func selectCPU(config: Config) -> Config {return (RAM: config.RAM, CPU: "3.2GHZ", GPU: config.GPU)}
// 传入一个配置 将其中GPU配置默认修改为NVidia
func selectGPU(config: Config) -> Config {return (RAM: config.RAM, CPU: config.CPU, GPU: "NVidia")}

enum Desktop {
    case Cube(Config)
    case Tower(Config)
    case Rack(Config)
}

// 一开始默认配置是： (0, "", "") as Config 假设我命名为defaultConfig
// 将该配置传入selectRAM(defaultConfig) 替换RAM为32后返回修改后的配置
// 同理传入selectGPU() 接着 传入selectGPU()
let aTower = Desktop.Tower(selectGPU(selectCPU(selectRAM((0, "", "") as Config))))

// 好吧 上面一堆代码配置PC机不直观 我们需要自定义一个符号来实现

infix operator <^>{associativity left}

func <^>(a:Config,f:(Config)->Config)->Config{
    return f(a)
}
let config = (0, "", "") <^> selectRAM  <^> selectCPU <^> selectGPU
let aCube = Desktop.Cube(config)


//: 一些使用案例


// 关联值可以是不同的类型 这里有NSURL UInt32 NSDate 以及Bool
enum UserAction {
    case OpenURL(url: NSURL)
    case SwitchProcess(processId: UInt32)
    case Restart(time: NSDate?, intoCommandLine: Bool)
}

// 文本选中情况 可以是单个 也可以多个选中
enum Selection {
    case None
    case Single(Range<Int>)
    case Multiple([Range<Int>])
}

// 这个就是二维码关联值 swift官方文档有相关例程
enum Barcode {
    case UPCA(numberSystem: Int, manufacturer: Int, product: Int, check: Int)
    case QRCode(productCode: String)
}

// Kqeue BSD/Darwin notification 中的使用
// system: https://www.freebsd.org/cgi/man.cgi?query=kqueue&sektion=2
enum KqueueEvent {
    case UserEvent(identifier: UInt, fflags: [UInt32], data: Int)
    case ReadFD(fd: UInt, data: Int)
    case WriteFD(fd: UInt, data: Int)
    case VnodeFD(fd: UInt, fflags: [UInt32], data: Int)
    case ErrorEvent(code: UInt, message: String)
}

// 就和游戏定义类型 内嵌了两个枚举定义 并且父枚举用例case都是关联值的
enum Wearable {
    enum Weight: Int {
        case Light = 1
        case Mid = 4
        case Heavy = 10
    }
    enum Armor: Int {
        case Light = 2
        case Strong = 8
        case Heavy = 20
    }
    case Helmet(weight: Weight, armor: Armor)
    case Breastplate(weight: Weight, armor: Armor)
    case Shield(weight: Weight, armor: Armor)
}
let woodenHelmet = Wearable.Helmet(weight: .Light, armor: .Light)


// 枚举中的方法
enum Device {
    case iPad, iPhone, AppleTV, AppleWatch
    // 这是定义的方法
    func introduced() -> String {
        switch self {
        case AppleTV: return "\(self) was introduced 2006"
        case iPhone: return "\(self) was introduced 2007"
        case iPad: return "\(self) was introduced 2010"
        case AppleWatch: return "\(self) was introduced 2014"
        }
    }
}
print (Device.iPhone.introduced())
// prints: "iPhone was introduced 2007"

// 还可以定义计算属性 根据枚举值来计算得到
enum Device_1 {
    case iPad, iPhone
    var year: Int {
        switch self {
        case iPhone: return 2007
        case iPad: return 2010
        }
    }
}
// 静态方法 调用时是以 类型名.方法名调用
enum Device_2{
    case AppleWatch
    static func fromSlang(term: String) -> Device_2? {
        if term == "iWatch" {
            return .AppleWatch
        }
        return nil
    }
}
print (Device_2.fromSlang("iWatch"))

// 可变方法
// 倘若方法中需要修改实例的值即self 方法前要加上mutating关键字
enum TriStateSwitch {
    case Off, Low, High
    mutating func next() {
        switch self {
        case Off:
            self = Low
        case Low:
            self = High
        case High:
            self = Off
        }
    }
}
var ovenLight = TriStateSwitch.Low
ovenLight.next()
//  .High
ovenLight.next()
// .Off


