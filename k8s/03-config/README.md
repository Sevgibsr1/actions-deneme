# Config ve Secret Yönetimi

Bu dizin, uygulamanın ConfigMap ve SealedSecret manifestlerini içerir. `app-secret` artık Bitnami SealedSecrets operatörü ile şifrelenmiş durumda tutulur; bu sayede repo içinde düz metin parola saklanmaz.

## SealedSecret Nasıl Güncellenir?

1. Plain secret dosyasını oluşturun (repo içine eklemeyin):
   ```bash
   cat <<'EOF' > k8s/03-config/secret-plain.yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: app-secret
     namespace: dev
   stringData:
     DB_PASSWORD: <yeni-sifre>
   EOF
   ```

2. Kendi cluster'ınızın SealedSecret public sertifikasını alın:
   ```bash
   kubeseal --controller-name=sealed-secrets --controller-namespace=sealed-secrets \
     --fetch-cert > sealed-secrets-cert.pem
   ```

3. Secret'ı şifreleyin:
   ```bash
   kubeseal --format yaml --cert sealed-secrets-cert.pem \
     < k8s/03-config/secret-plain.yaml \
     > k8s/03-config/secret.yaml
   ```

4. Repo durumunu kontrol edin ve yeni `secret.yaml` dosyasını commit'leyin.

5. Plain secret dosyasını silin:
   ```bash
   rm k8s/03-config/secret-plain.yaml sealed-secrets-cert.pem
   ```

`secret-plain.yaml` dosyası `.gitignore` içinde yer aldığı için yanlışlıkla commit edilmez.

