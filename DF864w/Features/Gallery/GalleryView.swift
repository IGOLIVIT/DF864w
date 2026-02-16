//
//  GalleryView.swift
//  DF864w
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct GalleryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ExportedItem.createdAt, order: .reverse) private var items: [ExportedItem]
    @State private var selectedItem: ExportedItem?
    @State private var itemToDelete: ExportedItem?
    @State private var shareURL: URL?

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.primaryBackground.ignoresSafeArea()
                if items.isEmpty {
                    EmptyStateView(
                        icon: "photo.stack",
                        title: "No Exports Yet",
                        message: "Export a photo from the editor to see it here."
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 100), spacing: Theme.Spacing.sm)
                        ], spacing: Theme.Spacing.sm) {
                            ForEach(items, id: \.id) { item in
                                GalleryThumbnailCell(
                                    item: item,
                                    onTap: { selectedItem = item },
                                    onDelete: { itemToDelete = item }
                                )
                            }
                        }
                        .padding(Theme.Spacing.md)
                    }
                }
            }
            .navigationTitle("Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedItem) { item in
                GalleryDetailSheet(
                    item: item,
                    onShare: { shareURL = item.localFileURL },
                    onDelete: {
                        try? modelContext.delete(item)
                        selectedItem = nil
                    },
                    onDismiss: { selectedItem = nil }
                )
            }
            .sheet(isPresented: .constant(shareURL != nil)) {
                if let url = shareURL {
                    ShareSheet(items: [url])
                        .onDisappear { shareURL = nil }
                }
            }
            .confirmationDialog("Delete Export", isPresented: .constant(itemToDelete != nil)) {
                Button("Delete", role: .destructive) {
                    if let i = itemToDelete {
                        try? modelContext.delete(i)
                        if let u = i.localFileURL { try? FileManager.default.removeItem(at: u) }
                    }
                    itemToDelete = nil
                }
                Button("Cancel", role: .cancel) { itemToDelete = nil }
            } message: {
                Text("Remove this export from the gallery? The file will be deleted.")
            }
        }
    }
}

struct GalleryThumbnailCell: View {
    let item: ExportedItem
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                if let thumbURL = item.thumbnailURL,
                   let data = try? Data(contentsOf: thumbURL),
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(Theme.Colors.cardSurface)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundStyle(Theme.Colors.secondaryText)
                        )
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.format)
                        .font(.caption2)
                        .foregroundStyle(.white)
                        .shadow(radius: 1)
                    Text(item.createdAt, style: .date)
                        .font(.caption2)
                        .foregroundStyle(.white)
                        .shadow(radius: 1)
                }
                .padding(4)
            }
            .frame(minHeight: 100)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.small))
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Open", action: onTap)
            Button("Delete", role: .destructive, action: onDelete)
        }
    }
}

struct GalleryDetailSheet: View {
    let item: ExportedItem
    let onShare: () -> Void
    let onDelete: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Colors.primaryBackground.ignoresSafeArea()
                if let url = item.localFileURL,
                   let data = try? Data(contentsOf: url),
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Text("Unable to load image")
                        .foregroundStyle(Theme.Colors.secondaryText)
                }
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { onDismiss() }
                        .foregroundStyle(Theme.Colors.accent)
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: onShare) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        Button(role: .destructive, action: onDelete) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
}

#Preview("Gallery") {
    GalleryView()
        .modelContainer(for: [ExportedItem.self], inMemory: true)
}
