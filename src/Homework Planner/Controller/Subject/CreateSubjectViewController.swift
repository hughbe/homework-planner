//
//  SubjectViewController.swift
//  Homework Planner
//
//  Created by Hugh Bellamy on 27/01/2018.
//  Copyright © 2018 Hugh Bellamy. All rights reserved.
//

import Foundation
import UIKit

public protocol CreateSubjectViewControllerDelegate {
    func createSubjectViewController(viewController: CreateSubjectViewController, didCreateSubject: SubjectViewModel)
    func didCancel(viewController: CreateSubjectViewController)
}

public class CreateSubjectViewController : UIViewController {
    @IBOutlet weak var containerView: ContainerView!
    @IBOutlet weak var colorButton: UIButton!
    @IBOutlet weak var selectColorView: SelectColorView!
    @IBOutlet weak var selectColorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var subjectsTableView: UITableView!
    @IBOutlet weak var teacherTextField: UITextField!
    @IBOutlet weak var actionsView: ActionsView!
    
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!

    public var delegate: CreateSubjectViewControllerDelegate?
    public var editingSubject: SubjectViewModel?

    private var completedSubjects: [String] = []
    private var selectColorsVisible = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        colorButton.layer.cornerRadius = 5
        selectColorView.colors = SubjectViewModel.Colors.all

        setSelectColorsVisible(selectColorsVisible: false, animated: false)
        
        // Can supply an existing subject to prefill.
        if let subject = editingSubject {
            nameTextField.text = subject.name
            teacherTextField.text = subject.teacher
            colorButton.backgroundColor = subject.color
            checkValid()
        } else {
            colorButton.backgroundColor = SubjectViewModel.Colors.randomColor()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isBeingPresented || isMovingToParentViewController {
            nameTextField.becomeFirstResponder()
        }
    }

    @IBAction func nameChanged(_ sender: Any) {
        checkValid()

        if let name = nameTextField.text {
            completedSubjects = SubjectViewModel.CommonSubjects.filter { subject in
                    subject.lowercased().contains(name.lowercased()) && subject != name
            }
            loadSubjectsSuggestions(showSuggestions: completedSubjects.count != 0, animated: true)
        }
    }
    
    @IBAction func nameNext(_ sender: Any) {
        teacherTextField.becomeFirstResponder()
    }
    
    @IBAction func teacherDone(_ sender: Any) {
        if isValid() {
            createSubject(sender)
        }
    }

    @IBAction func createSubject(_ sender: Any) {
        var createdSubject = editingSubject ?? SubjectViewModel()

        createdSubject.name = nameTextField.text ?? ""
        createdSubject.teacher = teacherTextField.text ?? ""
        createdSubject.color = colorButton.backgroundColor ?? UIColor.black

        do {
            try CoreDataStorage.shared.context.save()
            NotificationCenter.default.post(name: SubjectViewModel.Notifications.subjectsChanged, object: nil)

            view.endEditing(true)
            delegate?.createSubjectViewController(viewController: self, didCreateSubject: createdSubject)
        } catch let error as NSError {
            showAlert(error: error)
        }
    }

    @IBAction func cancel(_ sender: Any) {
        view.endEditing(true)
        delegate?.didCancel(viewController: self)
    }

    @IBAction func dismissKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
    private func isValid() -> Bool {
        guard let text = nameTextField.text else {
            return false
        }
        
        return text.count > 0
    }
    
    private func checkValid() {
        let isValid = self.isValid()
        
        actionsView.createButton.isEnabled = isValid
    }
    
    private func setSubjectsSuggestionConstraints(showSuggestions: Bool) {
        let subjectsHeight: CGFloat = 100
        
        subjectsTableView.reloadData()
        
        subjectsTableView.isHidden = !showSuggestions
        tableHeightConstraint.constant = showSuggestions ? subjectsHeight : 0
    }
    
    private func loadSubjectsSuggestions(showSuggestions: Bool, animated: Bool) {
        setSubjectsSuggestionConstraints(showSuggestions: showSuggestions)

        if animated {
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
}

extension CreateSubjectViewController : UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completedSubjects.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "SubjectCell")
        cell.textLabel?.text = completedSubjects[indexPath.row]

        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        nameTextField.text = cell?.textLabel?.text
        completedSubjects = []
        teacherTextField.becomeFirstResponder()
        loadSubjectsSuggestions(showSuggestions: false, animated: true)
    }
}

extension CreateSubjectViewController : SelectColorViewDelegate {
    @IBAction func changeColor(_ sender: Any) {
        setSelectColorsVisible(selectColorsVisible: !selectColorsVisible, animated: true)
    }

    public func setSelectColorsVisible(selectColorsVisible: Bool, animated: Bool) {
        self.selectColorsVisible = selectColorsVisible
        
        // Show the select color view and hide the subjects autocomplete view.
        selectColorView.selectedColor = colorButton.backgroundColor
        selectColorHeightConstraint.constant = selectColorsVisible ? 90 : 0
        setSubjectsSuggestionConstraints(showSuggestions: false)

        UIView.animate(withDuration: animated ? 0.2 : 0) {
            self.view.layoutIfNeeded()
        }
    }

    public func selectColorView(selectColorView: SelectColorView, didSelectColor color: UIColor) {
        colorButton.backgroundColor = color
        setSelectColorsVisible(selectColorsVisible: false, animated: true)
    }
}
