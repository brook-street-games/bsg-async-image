//
//  SampleView.swift
//
//  Created by JechtShot on 5/20/23.
//  Copyright © 2023 Brook Street Games. All rights reserved.
//

import SwiftUI

///
/// SwiftUI wrapper for *SampleViewController*.
///
struct SampleView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> SampleViewController {
        return SampleViewController(viewModel: SampleViewModel())
    }
    
    func updateUIViewController(_ uiViewController: SampleViewController, context: Context) {}
}
