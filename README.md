# How to Setup and Run This App
## Setup Flutter for Your Machine
- Follow the instructions [here](https://docs.flutter.dev/get-started/install/windows/mobile#configure-a-text-editor-or-ide) to setup an IDE to run a flutter application
- Further down the link above you need to download and install the Flutter SDK and update the path variable in your system
  - You can either [use VS Code to install](https://docs.flutter.dev/get-started/install/windows/mobile?tab=vscode) or [manually install flutter](https://docs.flutter.dev/get-started/install/windows/mobile?tab=download)
- Follow the rest of the setup steps
- Once finished run ```flutter doctor``` or ```flutter doctor -v``` in your command line to ensure a correct installation
  - You should get a ```• No issues found!``` message if everything is configured correctly
## Download the code and run the app in Chrome, on an Android/iOS emulator, or an Android/iOS physical device
- Clone the project files and open them in the IDE you configured earlier for flutter
- From the ```main.dart``` file located in ``/lib``, right click it and run the app in either Chrome or in an emulator of your choice
- FYI - It isn't fully functional as I didn't have enough time or help :(


# Here are the instructions to the hackathon, if needed: ais_hackathon

A punchcard tracking system for BYU AIS activities (hopefully)

## Welcome to the AIS Winter 2024 Hack-a-thon
### Introduction:
We are excited to announce the Winter 2024 Hack-a-thon! This event is designed to give students the opportunity to apply their knowledge and skills to a real-world problem. The competition is open to any active member of BYU's chapter of AIS, regardless of major or experience. We hope you have fun, learn new skills, and take advantage of this opportunity to showcase your talents and grow your personal portfolio! The winner's solution of this event will act as the baseline product for a service that AIS will use indefinitely.
Rules:
- Limit 6 people per team; individual participation is also welcome.
- You may work on the case from Friday, Feb 23 through Friday, Mar 1.
  You must submit your solution by 11:59 PM on the closing Friday.
- You may use any resources you have available to you, including the
  internet, textbooks, and other people.
- Your submission must be a working web or mobile application,
  applicable to the case.
- A one-page write up and cost analysis must be included with your
  submission, explaining the technology stack you used, the cost of the
  technology, and the reasoning behind your choices.
- Your one-page write up must also include a breakdown of the event
  categories that you decide with sufficient reasoning as to their purpose and tracking methods (to be explained in the case).
  The Case:
  BYU's chapter of the Association for Information Systems (AIS) is a beloved and ongoing tradition for many years. The actual club of BYU AIS is a registered chapter of the official Association for Information Systems organization (visit aisnet), with specific organization structures and formalities in place. The BYU AIS chapter holds many events and activities throughout each semester to engage students and involve them in friendship-building activities, recruiting efforts, and professional development.

In past years, members of BYU AIS have been able to keep track of events and activities through a physical card that was stamped at each event. This card was about the size of a business card, to conveniently fit in a wallet, and was intended to be a fun way to encourage members to attend events. This card was turned in at the end of the semester for a chance to win prizes via a drawing or extra credit at professors’ discretion.
Under the old format, the punch cards had ten stampable activities, under these categories:
- Discover (4 stamps)
    - Recruiting events (Info sessions)
    - Company/sponsors forums and meet-ups (AIS Sponsor Night)
- Connect (3 stamps)
    - Professor meetings and activities (e.g. Cookies and Milk, Pies
      with Professors)
- Socialize (2 stamps)
    - Monthly events (Opening Social, Pies with Professors, Gala, etc)
- Learn (2 stamps)
    - T.O.A. Technite (formerly known as Tech Talk)
    - IS Academy
- Serve (4 stamps)
    - A-Team
    - Service events (e.g., volunteering at events and club booths, etc.)

To qualify for the drawing, a student must have at least ten stamps, with at least one from each category. The more stamps a student had, the higher number of entries and higher dollar value of the prize they were eligible to win at the closing social of the year.

While this system has worked well in the past, it has become increasingly difficult to manage and track. The cards are often lost or forgotten, and there are additional logistical challenges in tracking and managing the cards. As the club has grown, we've felt the need to move to a digital format to track member participation and engagement.

Your task is to design and implement a digital solution to replace the physical punch card. Your solution should allow students to easily track their participation in AIS events and activities, and should allow the club to easily track and manage member participation. Your solution should also allow the club to easily verify that a student has met the requirements for the drawing at the end of the semester.

You may change the parameters of what qualifies for a “punch” and the distribution of activity types within the punch-card system, if your solution deems fit for a change to the structure.

If your solution implements a database, there must be sufficient security measures in place to protect the personal information of the students and faculty members.

You are free to design and implement your solution in any way you see fit, but you should consider the requirements of the solution below as you design and implement your solution. You should also consider the cost of your solution, and be prepared to explain the technology stack you used and the cost of the technology in your submission.
## Requirements of the Solution:
1. The solution must be a web or mobile application. If you choose a web application, it must be optimized for responsiveness to use on a mobile device.
2. Students must be able to easily track their participation and viewpast events and activities they've attended.
3. Only active members of AIS should be able to track their participation, but there should be an option to add a plus one so the club can keep an accurate count of event attendance.
4. Only verified AIS officers or club advisors should be able to "check-in" students at activities, registering their participation.
5. The club organization should be able to easily view and manage member participation and engagement.
6. Aggregate data should be available to club officers to track member participation and engagement.
7. The club should be able to easily verify that a student has met the requirements for the drawing at the end of the semester.
8. The solution should be cost-effective and easy to maintain.
   Thank you for your participation and good luck with the case!

