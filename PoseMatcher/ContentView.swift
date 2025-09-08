
import SwiftUI


struct ContentView: View {
//    @State private var images = []
    
    var body: some View {
        HStack{
            LiveViews()
           // StaticViews(image: <#CGImage#>)
            PhotoPickerView()
//           StaticViews(image:images)
        }
    }
}

#Preview {
    ContentView()
}
