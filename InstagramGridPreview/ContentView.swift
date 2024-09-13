import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var isImagePickerPresented = false
    @State private var selectedImage: UIImage?

    var body: some View {
        HomeView()        }
    }


