//
//  TrackCell.swift
//  LspPlayer
//
//  Created by Alice Kamyshenko on 14.12.2025.
//

import UIKit

final class TrackCell: UITableViewCell {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        coverImageView.layer.cornerRadius = 10
        coverImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
