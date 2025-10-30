def topla(a, b):
    return a + b

def test_topla():
    try:
        assert topla(2, 3) == 6  # Bilerek hata verdirebiliriz (değiştirilebilir)
        print("✅ Test başarılı!")
    except AssertionError:
        print("❌ Test başarısız oldu — Beklenen sonuç yanlış!")

test_topla()
