//
//  Array+Extensions.swift
//  ImageFeed
//
//  Created by Дмитрий Чалов on 18.10.2025.
//

extension Array {
    func withReplaced(itemAt index: Int, newValue: Element) -> [Element] {
        var copy = self
        copy[index] = newValue
        return copy
    }
}
