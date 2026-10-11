# FluentFlow.PodcastGenerator

Utilitário de consola que converte episódios em JSON (`Input/`) em MP3 (`Output/`) usando **Azure AI Speech** (TTS neural) + **FFmpeg**.

## Configuração (uma vez)

Cria `appsettings.Development.json` (já excluído pelo `.gitignore` da raiz):

```json
{ "AzureSpeech": { "Key": "<chave>", "Region": "westeurope" } }
```

Ou, em alternativa, usa user-secrets:

```powershell
cd utils\FluentFlow.PodcastGenerator
dotnet user-secrets set "AzureSpeech:Key" "<chave do recurso Speech>"
dotnet user-secrets set "AzureSpeech:Region" "westeurope"
```

Usa o FFmpeg de `src/FluentFlow.Api/ffmpeg/ffmpeg.exe`; se não existir, recorre ao do PATH (configurável em `Podcast:FfmpegPath`).

## Utilização

```powershell
dotnet run                      # gera episódios novos ou alterados
dotnet run -- en-a2-001.json    # só um episódio
dotnet run -- --force           # regenera tudo
dotnet run -- --validate        # só valida os JSON (não gasta quota)
```

No Visual Studio há perfis equivalentes em `launchSettings.json`.

## Publicação para a API

Se `Podcast:PublishDirectory` estiver definido (por omissão `../../src/FluentFlow.Api/App_Data/Podcasts`),
no fim de cada execução os `.json`/`.mp3` novos ou alterados são copiados para essa pasta.
A API lê o catálogo daí (configurável em `Podcasts:Path` no `appsettings.json` da API) e recarrega-o
automaticamente — não é preciso reiniciar. Em produção, copie o conteúdo de `Output/` para a pasta configurada no servidor.

## Saída (por episódio)

| Ficheiro | Conteúdo |
|---|---|
| `{id}.mp3` | Áudio normal, normalizado a -16 LUFS |
| `{id}.slow.mp3` | Versão lenta (`SlowTempo`, por omissão 0.85x) |
| `{id}.json` | Transcrição com `startMs`/`endMs` por fala (para legendas sincronizadas) |

As falas sintetizadas ficam em cache em `Cache/` (hash do SSML): reexecutar o mesmo texto não volta a gastar quota do Azure.

## Formato do JSON

Estrutura típica de um episódio: `intro` (narrador em pt-BR) → `dialogue` → `review` (cada fala repetida + explicação do narrador) → `outro`.

Cada speaker pode ter o seu próprio `language` (ex.: narrador `pt-BR`). Para o narrador, usa uma voz *Multilingual* (ex.: `pt-BR-MacerioMultilingualNeural`), que lê os trechos `[en]` em inglês com a mesma voz. Opcionalmente, `altVoices` troca para outra voz nesses trechos.

Marcação no texto:

| Marcação | Efeito |
|---|---|
| `[en]...[/en]` | Trecho em inglês, via `<lang xml:lang="en-US">` (voz *Multilingual*); ou `altVoices["en-US"]`, se definido |
| `[slow]...[/slow]` | Trecho lento (-35%), para demonstrar a pronúncia |
| `[pause]` / `[pause 1500]` | Pausa (600 ms por omissão), por exemplo para o aluno repetir |

Na revisão, repetir uma fala com exactamente o mesmo texto reaproveita a cache e não gasta quota.

Vê `Input/_template.json` (os ficheiros começados por `_` são ignorados). Lista de vozes: https://learn.microsoft.com/azure/ai-services/speech-service/language-support?tabs=tts
