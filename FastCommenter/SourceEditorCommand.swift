//
//  SourceEditorCommand.swift
//  FastCommenter
//
//  Created by Eric Baker on 28Sep2016.
//  Copyright © 2016 DuneParkSoftware, LLC. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        defer {
            completionHandler(nil)
        }

        var newSelections = [XCSourceTextRange]()
        var updatedLines = [Int]()

        invocation.buffer.selections.forEach { selection in
            if let range = selection as? XCSourceTextRange {
                (range.start.line...range.end.line).forEach { lineIndex in
                    guard lineIndex < invocation.buffer.lines.count else { return }
                    
                    if let line = invocation.buffer.lines[lineIndex] as? String {
                        if !line.hasPrefix("//") {
                            invocation.buffer.lines[lineIndex] = "// \(line)"
                            updatedLines.append(lineIndex)
                        }
                        else {
                            let offset = line.hasPrefix("// ") ? 3 : 2
                            let uncommentedLine = line.substring(from: line.index(line.startIndex, offsetBy: offset))
                            invocation.buffer.lines[lineIndex] = uncommentedLine
                            updatedLines.append(lineIndex)
                        }
                    }
                }

                let textRange = XCSourceTextRange()
                let newPosition = XCSourceTextPosition(line: range.end.line + 1, column: 0)
                textRange.start = newPosition
                textRange.end = newPosition

                newSelections.append(textRange)
            }
        }

        invocation.buffer.selections.setArray(newSelections)
    }
    
}
