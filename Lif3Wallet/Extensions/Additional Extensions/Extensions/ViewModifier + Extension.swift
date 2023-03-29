//
//  ViewModifier.swift
//  Book Gara
//
//  Created by Amrit Duwal on 6/11/22.
//

import SwiftUI
import Combine

struct TextFieldLimitModifer: ViewModifier {
    @Binding var value: String
    var length: Int

    func body(content: Content) -> some View {
        if #available(iOS 14, *) {
            content
                .onChange(of: $value.wrappedValue) {
                    value = String($0.suffix(length))
                }
        } else {
            content
                .onReceive(Just(value)) {
                    value = String($0.suffix(length))
                }
        }
    }
}

extension View {
    func limitInputLength(value: Binding<String>, length: Int) -> some View {
        self.modifier(TextFieldLimitModifer(value: value, length: length))
    }
}
