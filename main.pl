:- ['library_data.pl'].


all_books([prolog_fundamentals, recursion_in_depth, list_programming, ai_intro]).
all_students([ali, sara, omar, mona, yousef, nour, karim]).



%my_findall(X, Goal, L):-


%books_borrowed_by_student
filter_book(_, [], []).
filter_book(Student, [Book| Tail], [Book| ResultsTail]):-
    borrowed(Student, Book),
    !,
    filter_book(Student, Tail, ResultsTail).

filter_book(Student, [_| Tail], ResultsTail):-
    filter_book(Student, Tail, ResultsTail).



%borrowers_count
count_borrowers(_,[], 0).
count_borrowers(Book, [Student| Tail], Count):-
    borrowed(Student, Book),
    !,
    count_borrowers(Book, Tail, TailCount),
    Count is TailCount + 1.

count_borrowers(Book, [_| Tail], Count):-
    count_borrowers(Book, Tail, Count).


find_max([], CurrentMaxBook, _, CurrentMaxBook).

%most_borrowed_book
find_max([NextBook | RestBooks], CurrentMaxBook, CurrentMaxCount, FinalBestBook) :-
    borrowers_count(NextBook, NextCount),
    ( NextCount > CurrentMaxCount ->
        find_max(RestBooks, NextBook, NextCount, FinalBestBook);

        find_max(RestBooks, CurrentMaxBook, CurrentMaxCount, FinalBestBook)
    ).

%------------------------------------ Main Tasks-------------------------------------%
books_borrowed_by_student(Student, L) :-
    all_books(AllBooks),
    filter_book(Student, AllBooks, L).

borrowers_count(Book, Count):-
    count_borrowers(Book, all_students(Students), Count).

most_borrowed_book(B):-
    all_books(Books),
    find_max(Books, _, _, B).