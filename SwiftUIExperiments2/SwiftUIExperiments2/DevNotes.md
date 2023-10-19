#  Project for exploring SwiftUI 2023
Based on Jon's GolfScore App

Branches
--------

### v2
Shows how to use @Published without using Observed Objects
### v3
Shows the problem with using Structs in SwiftUI. Since they are passed by value, automatic binding and notifications only work for @State in the view. Parent data models are not automatically updated.
### v4
Not really ussable. It shows an infinite loop when transitioning to the Tee editing view. The reason turned out to be the use of a formatter object in multiple views in a NavigationStack.
### v5
The first stable branch that includes Course editing. (Create, Update, Delete)
### v6
Added a Score Card view, persisence of Courses, and a simple settings view that uses UserDefaults. Completed the main features of the Score input view, with custom shapes and validation logic.
### v7
In work - adding Group scoring

Persistence
-----------

### Courses

Course data should be loaded and saved in a background thread. I think the main reason is to allow for extending the app design to include sharing courses with other players through a web data service. Course data is not 'personalized'. I.e., the course data does not include data particular to any one user. Sharing course data with other app users is a natural and probably desired feature.

### Rounds

#### Rev 2

Even with a 1000 rounds, the total size should be in MB, so the app should handle that much data (as much as one image!)

Keep the rounds data in one file.

#### Original

To start with, I'm thinking that a round should be stored in its own file named with the id.

1. There is quite a bit of data associated with a round, and once a player has hundreds or thousands of rounds, loading and keeping every round in memory might present performance issues.
2. Probably more important is that if all rounds are in one file and the file becomes corrupted, it's possible that all Rounds could be lost.

### Database Posibilities

It might be good to store round data in a database rather than JSON files. The primary reason would be to support a 'Rounds' view that lists all of a players rounds, is searchable and filterable, while at the same time avoiding keeping all the round data in a single data repository.

Rounds View
    List
        Round1
        Round2
        Round3

This should be searchable and filterable to make it easy for a user to find a past round or rounds in a given state. The obvious data for a round might be Course (name), Tee Color, Date, and Round status (Incomplete, Complete, Submitted). In other words, we don't need all of the data for the rounds to display a Rounds Summary view.

The round summary data could be kept in a separate file, but that presents some coordination issues. For example, if a Round is added or deleted, the summary file must be updated accordingly.

 One way to get around all this would be to use a database to keep the round data. The key searchable fields in the database could be just the summary data. Once a round is selected, the entire round record could be retrieved and used.
 
 A compromise could be to have the database contain the key data for serachability and filtering, while the main Round data is kept in either separate files or as a blob of JSON in the database. This is a compromise because we could start with Rounds in individual files and read all files and generate the summary data on the fly. So, the development phases might be:
 
 1. Rounds in files, no summary file, read all rounds and generate summary view data on the fly.
 2. Rounds in files, summary file. Read summary file for RoundsView and then load individual rounds when chosen.
 3. Rounds in files, RoundsView based on a summary database, load individual rounds when chosen.
 4. Rounds and Summary in database, parse and us individual rounds when chosen.
 5. All data in a database. User could search for "All rounds where I made 2 birdies".


