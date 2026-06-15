import SwiftUI

struct TooltipContentView: View {
    let item: ProgressInfo?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(item?.dimension.title ?? "")
                .font(.system(size: 12, weight: .semibold))
            Text(item?.percentText ?? "")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
            Text(item?.detail ?? "")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .frame(width: 190, height: 72, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}
