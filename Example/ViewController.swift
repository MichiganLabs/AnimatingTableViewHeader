//
//  ViewController.swift
//  Example
//
//  Created by John DeLong on 5/11/16.
//  Copyright © 2016 delong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!

    let maxHeaderHeight: CGFloat = 88;
    let minHeaderHeight: CGFloat = 44;

    var previousScrollOffset: CGFloat = 0;

    @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var logoImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.headerHeightConstraint.constant = self.maxHeaderHeight
        updateHeader()
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 40
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel!.text = "Cell \(indexPath.row)"
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset

        let absoluteTop: CGFloat = 0;
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height;

        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom

        // Calculate new header height
        var newHeight = self.headerHeightConstraint.constant
        if isScrollingDown {
            newHeight = max(self.minHeaderHeight, self.headerHeightConstraint.constant - abs(scrollDiff))
        } else if isScrollingUp {
            newHeight = min(self.maxHeaderHeight, self.headerHeightConstraint.constant + abs(scrollDiff))
        }

        // Header needs to animate
        if newHeight != self.headerHeightConstraint.constant {
            self.headerHeightConstraint.constant = newHeight
            self.updateHeader()
            self.setScrollPosition(self.previousScrollOffset)
        }

        self.previousScrollOffset = scrollView.contentOffset.y
    }

    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.scrollViewDidStopScrolling()
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            self.scrollViewDidStopScrolling()
        }
    }

    func scrollViewDidStopScrolling() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let midPoint = self.minHeaderHeight + (range / 2)

        if self.headerHeightConstraint.constant > midPoint {
            self.expandHeader()
        } else {
            self.collapseHeader()
        }
    }

    func collapseHeader() {
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.2, animations: {
            self.headerHeightConstraint.constant = self.minHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }

    func expandHeader() {
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(0.2, animations: {
            self.headerHeightConstraint.constant = self.maxHeaderHeight
            self.updateHeader()
            self.view.layoutIfNeeded()
        })
    }

    func setScrollPosition(position: CGFloat) {
        self.tableView.contentOffset = CGPointMake(self.tableView.contentOffset.x, position)
    }

    func updateHeader() {
        let range = self.maxHeaderHeight - self.minHeaderHeight
        let openAmount = self.headerHeightConstraint.constant - self.minHeaderHeight
        let percentage = openAmount / range

        self.titleTopConstraint.constant = -openAmount + 10
        self.logoImageView.alpha = percentage
    }
}
