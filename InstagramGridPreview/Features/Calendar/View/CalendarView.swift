import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                List {
                    Section("Scheduled Posts") {
                        if viewModel.scheduledPosts.isEmpty {
                            Text("No scheduled posts")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(viewModel.scheduledPosts) { post in
                                ScheduledPostRow(post: post)
                            }
                            .onDelete(perform: viewModel.deletePost)
                        }
                    }
                }
            }
            .navigationTitle("Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.isAddingNewPost = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.isAddingNewPost) {
                NewPostView(date: selectedDate) { post in
                    viewModel.addPost(post)
                }
            }
        }
    }
}

// MARK: - Preview
struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarView()
    }
} 