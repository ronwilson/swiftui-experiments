//
//  CoursesModelLoader.swift
//  SwiftUIExperiments2
//
//  Created by Ron on 9/26/23.
//

import Foundation

/*
 class ArticleViewModel: ObservableObject {
     enum State {
         case idle
         case loading
         case failed(Error)
         case loaded(Article)
     }

     @Published private(set) var state = State.idle

     private let articleID: Article.ID
     private let loader: ArticleLoader

     init(articleID: Article.ID, loader: ArticleLoader) {
         self.articleID = articleID
         self.loader = loader
     }

     func load() {
         state = .loading

         loader.loadArticle(withID: articleID) { [weak self] result in
             switch result {
             case .success(let article):
                 self?.state = .loaded(article)
             case .failure(let error):
                 self?.state = .failed(error)
             }
         }
     }
 }

 */

//struct CourseModelLoader {
//    let courseModel: CourseModel
//    func load() {
//
//    }
//}
