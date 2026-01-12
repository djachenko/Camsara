//
//  HueRingsView.swift
//  Camsara
//
//  Created by justin on 11/1/26.
//

import SwiftUI

struct HueRingsView: View {
    var viewModel: HueRingsViewModel

    var body: some View {
        VStack {
            ForEach(viewModel.colorProviders.indices, id: \.self) { index in
                let provider = viewModel.colorProviders[index]

                HueRingView(viewModel: HueRingViewModel(colorsSource: provider))
            }
        }
    }
}

#Preview {
    HueRingsView(viewModel: .forPreview)
}
