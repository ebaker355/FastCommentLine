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

    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void) -> Void {
        defer {
            completionHandler(nil)
        }

        func enumerateSelectedLines(_ block: (String, Int) -> Bool) -> Void {
            var stop = false
            invocation.buffer.selections.forEach { selection in
                guard !stop else { return }

                if let range = selection as? XCSourceTextRange {
                    (range.start.line ... range.end.line).forEach { lineIndex in
                        guard !stop, lineIndex < invocation.buffer.lines.count else { return }

                        if let line = invocation.buffer.lines[lineIndex] as? String {
                            stop = block(line, lineIndex)
                        }
                    }
                }
            }
        }

        let commentChars = "//"

        // Examine all lines in the selection to see whether any need to be commented.
        // If any need to be commented, then comment the whole selection.
        // Otherwise, uncomment the whole selection.

        var commentSelection = false

        enumerateSelectedLines { line, lineIndex in
            if !line.hasPrefix(commentChars) {
                commentSelection = true
            }
            return commentSelection
        }

        var updatedLines = [Int]()

        enumerateSelectedLines { line, lineIndex in
            var updatedLine = line
            if commentSelection {

                updatedLine = "\(commentChars)\(line)"
            } else {

                updatedLine.removeFirst(commentChars.unicodeScalars.count)
            }
            invocation.buffer.lines[lineIndex] = updatedLine
            updatedLines.append(lineIndex)
            return false
        }

        if updatedLines.count > 0 {
            let range = XCSourceTextRange()
            let position = XCSourceTextPosition(line: updatedLines.last! + 1, column: 0)
            range.start = position
            range.end = position
            invocation.buffer.selections.setArray([range])
        }
    }
}
