import SwiftUI
import SwiftData

struct ClassesTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var sizeClass
    @Query(sort: \Class.updatedAt, order: .reverse) private var classes: [Class]

    @State private var isPresentingAddSheet = false
    @State private var classToEdit: Class?

    var body: some View {
        Group {
            if classes.isEmpty {
                ContentUnavailableView(
                    "No Classes Yet",
                    systemImage: "rectangle.stack.badge.plus",
                    description: Text("Tap the button below to start organizing your lectures.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.ultraThinMaterial)
                .toolbar(.hidden, for: .tabBar)
                .safeAreaInset(edge: .bottom) {
                    addClassButton
                        .padding()
                        .background(.thinMaterial, in: Capsule())
                        .padding(.bottom)
                }
            } else if sizeClass == .compact {
                List {
                    ForEach(classes) { course in
                        NavigationLink(value: course) {
                            ClassRow(course: course)
                        }
                    }
                    .onDelete(perform: deleteClasses)
                }
                .listStyle(.insetGrouped)
                .navigationDestination(for: Class.self, destination: ClassDetailView.init)
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 320), spacing: 24)], spacing: 24) {
                        ForEach(classes) { course in
                            NavigationLink(value: course) {
                                ClassCard(course: course)
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                Button("Edit") { classToEdit = course }
                                Button(role: .destructive) { delete(course) } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 24)
                    .padding(.bottom, 120)
                }
                .background(.ultraThinMaterial)
                .navigationDestination(for: Class.self, destination: ClassDetailView.init)
            }
        }
        .navigationTitle("Classes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { isPresentingAddSheet = true }) {
                    Label("Add Class", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .sheet(isPresented: $isPresentingAddSheet) {
            NavigationStack {
                ClassFormView()
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(item: $classToEdit) { course in
            NavigationStack {
                ClassFormView(course: course)
            }
            .presentationDetents([.medium, .large])
        }
        .safeAreaInset(edge: .bottom) {
            if !classes.isEmpty {
                addClassButton
                    .padding(.horizontal)
                    .padding(.bottom, 8)
            }
        }
    }

    private var addClassButton: some View {
        Button(action: { isPresentingAddSheet = true }) {
            Label("New Class", systemImage: "plus")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: 24))
    }

    private func deleteClasses(at offsets: IndexSet) {
        offsets.map { classes[$0] }.forEach(delete)
    }

    private func delete(_ course: Class) {
        modelContext.delete(course)
        try? modelContext.save()
    }
}

private struct ClassRow: View {
    @Bindable var course: Class

    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color(hex: course.colorHex))
                .frame(width: 44, height: 44)
                .overlay {
                    Text(String(course.name.prefix(2)).uppercased())
                        .font(.headline)
                        .foregroundStyle(.white)
                }
            VStack(alignment: .leading, spacing: 4) {
                Text(course.name)
                    .font(.headline)
                Text(course.summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

private struct ClassCard: View {
    @Bindable var course: Class

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(course.name)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "person")
                    .symbolVariant(.fill)
                    .foregroundStyle(.secondary)
            }
            Text("with \(course.instructor)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(course.summary)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Divider()
            VStack(alignment: .leading, spacing: 8) {
                Label("\(course.lectures.count) lectures", systemImage: "list.bullet.rectangle.portrait")
                if let latest = course.sortedLectures.first {
                    Label(latest.formattedDate, systemImage: "clock")
                }
            }
            .font(.footnote)
            .foregroundStyle(.secondary)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
        .shadow(radius: 4, y: 4)
    }
}

#Preview("Classes Tab") {
    NavigationStack {
        ClassesTabView()
    }
    .modelContainer(PreviewBootstrap.previewContainer)
}
