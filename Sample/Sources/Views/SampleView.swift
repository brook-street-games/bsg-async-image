//
//  SampleView.swift
//
//  Created by JechtSh0t on 5/20/23.
//  Copyright © 2023 Brook Street Games LLC. All rights reserved.
//

import SwiftUI

///
/// Swift UI wrapper for *SampleViewController*.
///
struct SampleView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> SampleViewController {
        return SampleViewController(viewModel: SampleViewModel())
    }
    
    func updateUIViewController(_ uiViewController: SampleViewController, context: Context) {}
}
