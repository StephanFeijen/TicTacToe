namespace DefaultPublisher;

enum 70101 "TTT Game Status"
{
    Extensible = false;

    value(0; Open)
    {
        Caption = 'Open';
    }
    value(1; "X Won")
    {
        Caption = 'X Won';
    }
    value(2; "O Won")
    {
        Caption = 'O Won';
    }
    value(3; Draw)
    {
        Caption = 'Draw';
    }
}
