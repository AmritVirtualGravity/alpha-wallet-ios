//
//  View.swift
//  Book Gara
//
//  Created by Amrit Duwal on 6/3/22.
//

import SwiftUI

extension View {
    /// Navigate to a new view.
    /// - Parameters:
    ///   - view: View to navigate to.
    ///   - binding: Only navigates when this condition is `true`.
//    func navigate<NewView: View>(to view: NewView, when binding: Binding<Bool>) -> some View {
//        NavigationView {
//            ZStack {
//                self
//                    .navigationBarTitle("")
//                    .navigationBarHidden(true)
//
//                NavigationLink(
//                    destination: view
//                        .navigationBarTitle("")
//                        .navigationBarHidden(true),
//                    isActive: binding
//                ) {
//                    EmptyView()
//                }
//            }
//        }
//        .navigationViewStyle(.stack)
//    }
    
    
}

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

extension RandomAccessCollection {
    func indexed() -> Array<(offset: Int, element: Element)> {
        Array(enumerated())
    }
}


// MARK: - Debugging -
extension View {
    public func _printingChanges() -> Self {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            Self._printChanges()
            return self
        } else {
            return self
        }
    }
}


struct PrimaryLabel: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .padding()
                .background(.black)
                .foregroundColor(.white)
                .font(.largeTitle)
                .cornerRadius(10)
        } else {
            // Fallback on earlier versions
            content
                .padding()
//                .background(.black)
                .foregroundColor(.white)
                .font(.largeTitle)
                .cornerRadius(10)
        }
    }
}
/* uses
Text("Hello World")
    .modifier(PrimaryLabel())
*/


extension UIView {
       
       func allSubviews() -> [UIView] {
           var res = self.subviews
           for subview in self.subviews {
               let riz = subview.allSubviews()
               res.append(contentsOf: riz)
           }
           return res
       }
   }

struct Tool {
    static func hideNavigationBar() {
        UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.allSubviews().forEach({ (v) in
            if let view = v as? UINavigationBar {
                view.isHidden = true
            }
        })
    }
    
    static func showNavigationBar() {
        UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.allSubviews().forEach({ (v) in
            if let view = v as? UINavigationBar {
                view.isHidden = false
            }
        })
    }
    
    static func showTabBar() {
        UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.allSubviews().forEach({ (v) in
            if let view = v as? UITabBar {
                view.isHidden = false
            }
        })
    }
    
    static func hiddenTabBar() {
        UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.allSubviews().forEach({ (v) in
            if let view = v as? UITabBar {
                view.isHidden = true
            }
        })
    }
}

struct ShowTabBar: ViewModifier {
      func body(content: Content) -> some View {
          return content.padding(.zero).onAppear {
              Tool.showTabBar()
          }
      }
  }
  struct HiddenTabBar: ViewModifier {
      func body(content: Content) -> some View {
          return content.padding(.zero).onAppear {
              Tool.hiddenTabBar()
          }
      }
  }
  

extension View {
      func showTabBar() -> some View {
          return self.modifier(ShowTabBar())
      }
      func hiddenTabBar() -> some View {
          return self.modifier(HiddenTabBar())
      }
  }


//extension View {
//    /// Navigate to a new view.
//    /// - Parameters:
//    ///   - view: View to navigate to.
//    ///   - binding: Only navigates when this condition is `true`.
//    func navigate<NewView: View>(to view: NewView, when binding: Binding<Bool>) -> some View {
//        NavigationView {
//            ZStack {
//                self
//                    .navigationBarTitle("")
//                    .navigationBarHidden(true)
//
//                NavigationLink(
//                    destination: view
//                        .navigationBarTitle("")
//                        .navigationBarHidden(true),
//                    isActive: binding
//                ) {
//                    EmptyView()
//                }
//            }
//        }
//        .navigationViewStyle(.stack)
//    }
//}


extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
   @ViewBuilder
   func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
        if conditional {
            content(self)
        } else {
            self
        }
    }
}
//
//
//struct BookingEmptyView: View {
//    let text: String
//    var body: some View {
//        VStack(spacing: 5) {
//            Image("info")
//                .renderingMode(.template)
//                .resizable()
//                .opacity(0.4)
//                .frame(width: 50, height: 50)
//                .foregroundColor(Color(darkestGreyColor))
//            Spacer().frame(height: 8)
//            Text(text)
//                .font(Font(mediumFont20))
//                .foregroundColor(Color(darkestGreyColorDim))
//                .multilineTextAlignment(.center)
//            
//        }.padding()
//    }
//}

