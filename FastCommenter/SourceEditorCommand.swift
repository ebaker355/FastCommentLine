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
        let commentChars = "//"

        invocation.buffer.selections.forEach { selection in
            if let range = selection as? XCSourceTextRange {
                (range.start.line...range.end.line).forEach { lineIndex in
                    guard lineIndex < invocation.buffer.lines.count else { return }

                    if var line = invocation.buffer.lines[lineIndex] as? String {
                        // See if the line needs to be commented or uncommented.
                        if !line.hasPrefix(commentChars) {
                            invocation.buffer.lines[lineIndex] = "\(commentChars)\(line)"
                            updatedLines.append(lineIndex)
                        }
                        else {
                            // Uncomment
                            line.characters.removeFirst(commentChars.unicodeScalars.count)
                            invocation.buffer.lines[lineIndex] = line
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
