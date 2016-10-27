//: ## Swift and Cocoa Touch
//:
//: Swift is designed to provide seamless interoperability with Cocoa Touch, the set of Apple frameworks you use to develop apps for iOS. As you walk through the rest of the lessons, it helps to have a basic understanding of how Swift interacts with Cocoa Touch.
//:
//: So far, you’ve been working exclusively with data types from the Swift standard library. The _Swift standard library_ is a set of data types and capabilities designed for Swift and baked into the language. Types like `String` and `Array` are examples of data types you see in the standard library.
//:
//seamless 无缝的;   无漏洞的;  
//interoperability 互用性，协同工作的能力
//interacts 相互作用
//exclusively 唯一地;   专门地，特定地;   专有地;   排外地;  
//standard 标准的
//capabilities  容量;能力
let sampleString: String = "hello"
let sampleArray: Array = [1, 2, 3.1415, 23, 42]

//: > **Experiment**:
//: > Read about types in the standard library by Option-clicking the type in Xcode. Option-click on `String` and `Array` in the code above while looking at this playground in Xcode.
//:
//: When writing iOS apps, you’ll be using more than the Swift standard library. One of the most frequently used frameworks in iOS app development is UIKit. _UIKit_ contains useful classes for working with the _UI (user interface)_ layer of your app.
//:
//: To get access to UIKit, simply import it as a module into any Swift file or playground.
//:
import UIKit

//: After importing UIKit, you can use Swift syntax with UIKit types and with their methods, properties, and so on.
//:
let redSquare = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
redSquare.backgroundColor = UIColor.redColor()
//breadth 宽度;   宽容;
//knowledge 了解，理解;   知识
// full-fledged 成熟的 fledged 羽翼丰满的，会飞的
//extent 程度;   长度;   广大地域;   扣押;  
//visualizing 设想，想像( visualize的现在分词 );
//prototyping 原型机制造;  
//: Many of the classes you’ll be introduced to in the lessons come from UIKit, so you’ll see this import statement often.
//:
//: With this breadth of knowledge about Swift, you’re about to jump into making a full-fledged app in the next lesson. Although this lesson is the extent of playgrounds you’ll work with for now, remember that they can be a powerful tool in app development for anything from debugging, to visualizing complex code, to rapid prototyping.
//:
//: [Previous](@previous)
