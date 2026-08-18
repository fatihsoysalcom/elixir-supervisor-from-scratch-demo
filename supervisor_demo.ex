defmodule MyWorker do
  use GenServer

  # Client API for interacting with the worker
  def start_link do
    GenServer.start_link(__MODULE__, 0, name: __MODULE__)
  end

  def get_count do
    GenServer.call(__MODULE__, :get_count)
  end

  def increment do
    GenServer.call(__MODULE__, :increment)
  end

  def crash do
    GenServer.call(__MODULE__, :crash)
  end

  # GenServer Callbacks
  @impl true
  def init(initial_count) do
    IO.puts "MyWorker: Initializing with count #{initial_count}"
    {:ok, initial_count}
  end

  @impl true
  def handle_call(:get_count, _from, count) do
    IO.puts "MyWorker: Current count is #{count}"
    {:reply, count, count}
  end

  @impl true
  def handle_call(:increment, _from, count) do
    new_count = count + 1
    IO.puts "MyWorker: Incrementing count to #{new_count}"
    {:reply, new_count, new_count}
  end

  @impl true
  def handle_call(:crash, _from, count) do
    IO.puts "MyWorker: CRASHING NOW! Current count was #{count}"
    # This will cause the GenServer to exit abnormally, triggering the supervisor to restart it.
    raise "Simulated worker crash!"
    {:reply, :crashed, count} # This line won't be reached
  end

  @impl true
  def terminate(reason, state) do
    IO.puts "MyWorker: Terminating. Reason: #{inspect(reason)}, State: #{state}"
    :ok
  end
end

defmodule MySupervisor do
  use Supervisor

  # Client API for starting the supervisor
  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  # Supervisor Callback: This is where we define the supervision tree.
  @impl true
  def init(:ok) do
    IO.puts "MySupervisor: Initializing..."

    # Define the child processes that this supervisor will manage.
    # We're defining MyWorker as a child here.
    children = [
      # This is the child specification for MyWorker.
      # `id`: A unique identifier for the child.
      # `start`: The function to call to start the child process.
      # `restart`: Defines when the supervisor should restart the child.
      #            `:permanent` means it's always restarted if it terminates.
      # `type`: Indicates if it's a `:worker` or another `:supervisor`.
      # `shutdown`: How long to wait for the child to terminate gracefully.
      %{ 
        id: MyWorker,
        start: {MyWorker, :start_link, []},
        restart: :permanent, 
        type: :worker,
        shutdown: 5000 
      }
    ]

    # Define the supervision strategy.
    # `:one_for_one` means if a child terminates, only that child is restarted.
    # Other strategies include `:one_for_all` and `:rest_for_one`.
    opts = [strategy: :one_for_one, name: __MODULE__]

    IO.puts "MySupervisor: Starting children with strategy #{inspect(opts[:strategy])}"
    Supervisor.init(children, opts)
  end
end

# Main application logic to demonstrate the supervisor's behavior
defmodule SupervisorDemo do
  def run do
    IO.puts "\n--- Starting Supervisor Demo ---"

    # 1. Start the supervisor. It will automatically start MyWorker as its child.
    {:ok, supervisor_pid} = MySupervisor.start_link()
    IO.puts "Supervisor started with PID: #{inspect(supervisor_pid)}"

    # Give processes a moment to link and start
    Process.sleep(100)

    # 2. Interact with the worker before it crashes
    IO.puts "\n--- Initial Worker Interaction ---"
    initial_count = MyWorker.get_count()
    IO.puts "Worker's initial count: #{initial_count}"

    MyWorker.increment()
    MyWorker.increment()
    count_before_crash = MyWorker.get_count()
    IO.puts "Worker's count before crash: #{count_before_crash}"

    # 3. Simulate a worker crash
    IO.puts "\n--- Simulating Worker Crash ---"
    # This call will cause MyWorker to raise an error and crash.
    # The supervisor will detect this and restart it.
    MyWorker.crash()

    # Give the supervisor a moment to react and restart the worker
    Process.sleep(100)

    # 4. Interact with the (restarted) worker
    IO.puts "\n--- Post-Crash Worker Interaction ---"
    # Because the worker was restarted, its internal state (count) should be reset to 0.
    restarted_count = MyWorker.get_count()
    IO.puts "Worker's count after restart: #{restarted_count}"
    # We expect this to be 0 again, demonstrating the restart and state reset.

    # 5. Clean up by stopping the supervisor
    IO.puts "\n--- Stopping Supervisor ---"
    Supervisor.stop(supervisor_pid)
    IO.puts "Supervisor stopped."
    IO.puts "--- Demo Finished ---"
  end
end

# Automatically run the demo when the script is executed
SupervisorDemo.run()
