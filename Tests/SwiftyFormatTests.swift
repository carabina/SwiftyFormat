import XCTest
import Nimble
import SwiftyFormat

final class SwiftyFormatTests: XCTestCase {
   let format = "Hello #{{name|Mr(s)}}, I have #{{cookies|several}} cookies for you. Bye #{{name}}"

   func testDefault() {
      expect(NSAttributedString(format: self.format) { _ in nil }) == NSAttributedString(string: "Hello Mr(s), I have several cookies for you. Bye ")
   }

   func testMapping() {
      let result = NSAttributedString(format: self.format) { key in
         switch key {
         case "name":
            return "Jill"
         case "cookies":
            return 5
         default:
            XCTFail()
            return nil
         }
      }

      expect(result) == NSAttributedString(string: "Hello Jill, I have 5 cookies for you. Bye Jill")
   }

   func testAttributedMapping() {
      let name = NSAttributedString(string: "Jack", attributes: [NSForegroundColorAttributeName: UIColor.redColor()])
      let cookies = NSAttributedString(string: "100", attributes: [NSForegroundColorAttributeName: UIColor.blueColor()])
      let result = NSAttributedString(format: self.format) { key in
         switch key {
         case "name":
            return name
         case "cookies":
            return cookies
         default:
            XCTFail()
            return nil
         }
      }

      let expected = NSMutableAttributedString(string: "Hello ")
      expected.appendAttributedString(name)
      expected.appendAttributedString(NSAttributedString(string: ", I have "))
      expected.appendAttributedString(cookies)
      expected.appendAttributedString(NSAttributedString(string: " cookies for you. Bye "))
      expected.appendAttributedString(name)

      expect(result) == expected
   }

   func testPrefixAndSuffix() {
      let format = "#{{user}} mentioned you in a comment#{{comment|| \"|\"}}"

      let result = NSAttributedString(format: format) { key in
         switch key {
         case "user":
            return NSAttributedString(string: "Jack")
         case "comment":
            return NSAttributedString(string: "How are you Jill?")
         default:
            XCTFail()
            return nil
         }
      }

      expect(result) == NSAttributedString(string: "Jack mentioned you in a comment \"How are you Jill?\"")
   }

   func testAbsentValueWithPrefixAndSuffix() {
      let format = "#{{user}} mentioned you in a comment#{{comment|| \"|\"}}"

      let result = NSAttributedString(format: format) { key in
         switch key {
         case "user":
            return "Jack"
         case "comment":
            return nil
         default:
            XCTFail()
            return nil
         }
      }

      expect(result) == NSAttributedString(string: "Jack mentioned you in a comment")
   }

   func testDictionary() {
      let format = "#{{user}} mentioned you in a comment#{{comment|| \"|\"}}"

      let result = NSAttributedString(format: format, mapping: ["user": "Jack", "comment": "How are you Jill?"])

      expect(result) == NSAttributedString(string: "Jack mentioned you in a comment \"How are you Jill?\"")
   }

   func testMultiline() {
      let format = "#{{first|||\n}}#{{second||\n}}"

      let result = NSAttributedString(format: format, mapping: ["first": 1, "second": 2])

      expect(result) == NSAttributedString(string: "1\n\n2")
   }

   func testString() {
      expect(String(format: self.format, mapping: ["name": "Jack", "cookies": 6])) ==  "Hello Jack, I have 6 cookies for you. Bye Jack"

      expect(String(format: self.format, mapping: [:])) ==  "Hello Mr(s), I have several cookies for you. Bye "
   }

   func testAttributes() {
      let greetingFormat = "Hello #{{name}}"

      let nameAttributes: [String: AnyObject] = [
         NSFontAttributeName: UIFont.boldSystemFontOfSize(12),
         NSForegroundColorAttributeName: UIColor.redColor()
      ]

      let attributedName = NSAttributedString(string: "Jack", attributes: nameAttributes)

      let greetingAttributes: [String: AnyObject] = [
         NSFontAttributeName: UIFont.systemFontOfSize(12),
         NSForegroundColorAttributeName: UIColor.greenColor(),
         NSUnderlineStyleAttributeName: 1
      ]

      let attributedGreeting = NSAttributedString(format: greetingFormat,
                                                  attributes: greetingAttributes,
                                                  mapping: ["name": attributedName])

      var range: NSRange = NSRange(location: 0, length: 0)

      let realAttributes = attributedGreeting.attributesAtIndex(1, effectiveRange: &range)

      expect(realAttributes).to(equal(greetingAttributes as NSDictionary))

      let realNameAttributes: [String: AnyObject] = attributedGreeting.attributesAtIndex(8, effectiveRange: &range)

      var expectedNameAttributes = nameAttributes
      expectedNameAttributes[NSUnderlineStyleAttributeName] = 1
      expect(realNameAttributes).to(equal(expectedNameAttributes as NSDictionary))
   }
}
