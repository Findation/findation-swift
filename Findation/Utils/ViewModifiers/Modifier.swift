//
//  Modifier.swift
//  Findation
//
//  Created by Soomin Im on 8/4/25.
//
import SwiftUI

struct LargeTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 34, weight: .regular))
            .lineSpacing(7)
    }
}

struct Title1: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 28, weight: .regular))
            .lineSpacing(6)
    }
}

struct Title2: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 22, weight: .regular))
            .lineSpacing(6)
    }
}

struct Title3: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 20, weight: .regular))
            .lineSpacing(5)
    }
}

struct Headline: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 17, weight: .medium))
            .lineSpacing(5)
    }
}

struct Bodytext: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .regular))
            .lineSpacing(6)
    }
}

struct CallOut: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .regular))
            .lineSpacing(5)
    }
}

struct Subhead: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 15, weight: .regular))
            .lineSpacing(5)
    }
}

struct Footnote: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 13, weight: .regular))
            .lineSpacing(5)
    }
}

struct Caption1: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 12, weight: .regular))
            .lineSpacing(4)
    }
}

struct Caption2: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 11, weight: .regular))
            .lineSpacing(2)
    }
}

struct TimeLarge: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 64, weight: .ultraLight))
            .lineSpacing(1)
    }
}

struct TimeSmall: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 48, weight: .ultraLight))
            .lineSpacing(1)
    }
}


extension View {
    func bodyText() -> some View {
        self.modifier(LargeTitle())
    }

    func heading1() -> some View {
        self.modifier(Title1())
    }

    func heading2() -> some View {
        self.modifier(Title2())
    }

    func captionText() -> some View {
        self.modifier(Title3())
    }
    func headline() -> some View {
        self.modifier(Headline())
    }

    func bodytext() -> some View {
        self.modifier(Bodytext())
    }

    func callOut() -> some View {
        self.modifier(CallOut())
    }

    func subhead() -> some View {
        self.modifier(Subhead())
    }
    func footNote() -> some View {
        self.modifier(Footnote())
    }

    func caption1() -> some View {
        self.modifier(Caption1())
    }

    func caption2() -> some View {
        self.modifier(Caption2())
    }

    func timeLarge() -> some View {
        self.modifier(TimeLarge())
    }
    func timeSmall() -> some View {
        self.modifier(TimeSmall())
    }
}
