from hello import main


def test_main_prints_expected_output(capsys):
    main()
    captured = capsys.readouterr()

    assert "Hello, World!" in captured.out
    assert "Bu bir test uygulamasıdır." in captured.out

