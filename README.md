# Elixir Supervisor from Scratch Demo

This Elixir example demonstrates how to build a custom Supervisor from scratch. It defines a simple GenServer worker that can crash, and a Supervisor that monitors and automatically restarts the worker, showcasing Elixir's fault-tolerance capabilities and the `init/1` callback for defining child specifications.

## Language

`elixir`

## How to Run

1. Save the code as `supervisor_demo.ex`.
2. Ensure you have Elixir installed (https://elixir-lang.org/install.html).
3. Run it from your terminal using `elixir supervisor_demo.ex`.

## Original Article

This example accompanies the Turkish article: [Elixir'de Dağıtık Sistemler Oluşturma: Bölüm 5 — Supervisor'ı Sıfırdan İnşa Etmek](https://fatihsoysal.com/blog/elixirde-dagitik-sistemler-olusturma-bolum-5-supervisori-sifirdan-insa-etmek/).

## License

MIT — see [LICENSE](LICENSE).
