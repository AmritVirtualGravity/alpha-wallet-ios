
import SwiftUI
import SVGKit

struct SVGKFastImageViewSUI:UIViewRepresentable
{
    @Binding var url:URL
    @Binding var size:CGSize
    
    func makeUIView(context: Context) -> SVGKFastImageView {
       
       // let url = url
      //  let data = try? Data(contentsOf: url)
        let svgImage = SVGKImage(contentsOf: url)
        return SVGKFastImageView(svgkImage: svgImage ?? SVGKImage())
        
    }
    func updateUIView(_ uiView: SVGKFastImageView, context: Context) {
        uiView.image = SVGKImage(contentsOf: url)
        
        uiView.image.size = size
    }
    
    
}

//struct SVGImage_Previews: PreviewProvider {
//    static var previews: some View {
//        SVGKFastImageViewSUI(url: .constant(URL(string:"https://dev.w3.org/SVG/tools/svgweb/samples/svg-files/android.svg")!), size: .constant(CGSize(width: 100,height: 100)))
//    }
//}


struct setSvgImage: View {
    var imageUrl: String
    var width: CGFloat  = 30
    var height: CGFloat = 30
    var body: some View {
        
        if let url = URL(string: imageUrl), imageUrl.contains("svg") {
            SVGKFastImageViewSUI(url: .constant(url), size: .constant(CGSize(width: width,height: height)))
            //        .frame(width: 30, height: 30)
            //        .clipShape(Circle())
        } else {
            AsyncImage(
                url: imageUrl ,
                placeholder: { PlaceHolderImageView() },
                image: { Image(uiImage: $0).resizable() })
        }
    }
    
}
