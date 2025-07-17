InputEventMIDI

Inherits: InputEvent < Resource < RefCounted < Object

Represents a MIDI message from a MIDI device, such as a musical keyboard.
Description

InputEventMIDI stores information about messages from MIDI (Musical Instrument Digital Interface) devices. These may include musical keyboards, synthesizers, and drum machines.

MIDI messages can be received over a 5-pin MIDI connector or over USB. If your device supports both be sure to check the settings in the device to see which output it is using.

By default, Godot does not detect MIDI devices. You need to call OS.open_midi_inputs(), first. You can check which devices are detected with OS.get_connected_midi_inputs(), and close the connection with OS.close_midi_inputs().

func _ready():
	OS.open_midi_inputs()
	print(OS.get_connected_midi_inputs())

func _input(input_event):
	if input_event is InputEventMIDI:
		_print_midi_info(input_event)

func _print_midi_info(midi_event):
	print(midi_event)
	print("Channel ", midi_event.channel)
	print("Message ", midi_event.message)
	print("Pitch ", midi_event.pitch)
	print("Velocity ", midi_event.velocity)
	print("Instrument ", midi_event.instrument)
	print("Pressure ", midi_event.pressure)
	print("Controller number: ", midi_event.controller_number)
	print("Controller value: ", midi_event.controller_value)

Note: Godot does not support MIDI output, so there is no way to emit MIDI messages from Godot. Only MIDI input is supported.

Note: On the Web platform, using MIDI input requires a browser permission to be granted first. This permission request is performed when calling OS.open_midi_inputs(). MIDI input will not work until the user accepts the permission request.
Tutorials

    MIDI Message Status Byte List

    Wikipedia General MIDI Instrument List

    Wikipedia Piano Key Frequencies List

Properties

int
	

channel
	

0

int
	

controller_number
	

0

int
	

controller_value
	

0

int
	

instrument
	

0

MIDIMessage
	

message
	

0

int
	

pitch
	

0

int
	

pressure
	

0

int
	

velocity
	

0
Property Descriptions

int channel = 0

    void set_channel(value: int)

    int get_channel()

The MIDI channel of this message, ranging from 0 to 15. MIDI channel 9 is reserved for percussion instruments.

int controller_number = 0

    void set_controller_number(value: int)

    int get_controller_number()

The unique number of the controller, if message is @GlobalScope.MIDI_MESSAGE_CONTROL_CHANGE, otherwise this is 0. This value can be used to identify sliders for volume, balance, and panning, as well as switches and pedals on the MIDI device. See the General MIDI specification for a small list.

int controller_value = 0

    void set_controller_value(value: int)

    int get_controller_value()

The value applied to the controller. If message is @GlobalScope.MIDI_MESSAGE_CONTROL_CHANGE, this value ranges from 0 to 127, otherwise it is 0. See also controller_value.

int instrument = 0

    void set_instrument(value: int)

    int get_instrument()

The instrument (also called program or preset) used on this MIDI message. This value ranges from 0 to 127.

To see what each value means, refer to the General MIDI's instrument list. Keep in mind that the list is off by 1 because it does not begin from 0. A value of 0 corresponds to the acoustic grand piano.

MIDIMessage message = 0

    void set_message(value: MIDIMessage)

    MIDIMessage get_message()

Represents the type of MIDI message (see the MIDIMessage enum).

For more information, see the MIDI message status byte list chart.

int pitch = 0

    void set_pitch(value: int)

    int get_pitch()

The pitch index number of this MIDI message. This value ranges from 0 to 127.

On a piano, the middle C is 60, followed by a C-sharp (61), then a D (62), and so on. Each octave is split in offsets of 12. See the "MIDI note number" column of the piano key frequency chart a full list.

int pressure = 0

    void set_pressure(value: int)

    int get_pressure()

The strength of the key being pressed. This value ranges from 0 to 127.

Note: For many devices, this value is always 0. Other devices such as musical keyboards may simulate pressure by changing the velocity, instead.

int velocity = 0

    void set_velocity(value: int)

    int get_velocity()

The velocity of the MIDI message. This value ranges from 0 to 127. For a musical keyboard, this corresponds to how quickly the key was pressed, and is rarely above 110 in practice.

Note: Some MIDI devices may send a @GlobalScope.MIDI_MESSAGE_NOTE_ON message with 0 velocity and expect it to be treated the same as a @GlobalScope.MIDI_MESSAGE_NOTE_OFF message. If necessary, this can be handled with a few lines of code:

func _input(event):
	if event is InputEventMIDI:
		if event.message == MIDI_MESSAGE_NOTE_ON and event.velocity > 0:
			print("Note pressed!")


---
https://docs.godotengine.org/en/stable/classes/class_os.html#class-os-method-open-midi-inputs

void open_midi_inputs()

Initializes the singleton for the system MIDI driver, allowing Godot to receive InputEventMIDI. See also get_connected_midi_inputs() and close_midi_inputs().

Note: This method is implemented on Linux, macOS, Windows, and Web.

Note: On the Web platform, Web MIDI needs to be supported by the browser. For the time being, it is currently supported by all major browsers, except Safari.

Note: On the Web platform, using MIDI input requires a browser permission to be granted first. This permission request is performed when calling open_midi_inputs(). The browser will refrain from processing MIDI input until the user accepts the permission request.




class_+od

OS

Inherits: Object

Provides access to common operating system functionalities.
Description

The OS class wraps the most common functionalities for communicating with the host operating system, such as the video driver, delays, environment variables, execution of binaries, command line, etc.

Note: In Godot 4, OS functions related to window management, clipboard, and TTS were moved to the DisplayServer singleton (and the Window class). Functions related to time were removed and are only available in the Time class.
Tutorials

    Operating System Testing Demo

Properties

bool
	

delta_smoothing
	

true

bool
	

low_processor_usage_mode
	

false

int
	

low_processor_usage_mode_sleep_usec
	

6900
Methods

void
	

alert(text: String, title: String = "Alert!")

void
	

close_midi_inputs()

void
	

crash(message: String)

int
	

create_instance(arguments: PackedStringArray)

int
	

create_process(path: String, arguments: PackedStringArray, open_console: bool = false)

void
	

delay_msec(msec: int) const

void
	

delay_usec(usec: int) const

int
	

execute(path: String, arguments: PackedStringArray, output: Array = [], read_stderr: bool = false, open_console: bool = false)

Dictionary
	

execute_with_pipe(path: String, arguments: PackedStringArray, blocking: bool = true)

Key
	

find_keycode_from_string(string: String) const

String
	

get_cache_dir() const

PackedStringArray
	

get_cmdline_args()

PackedStringArray
	

get_cmdline_user_args()

String
	

get_config_dir() const

PackedStringArray
	

get_connected_midi_inputs()

String
	

get_data_dir() const

String
	

get_distribution_name() const

PackedByteArray
	

get_entropy(size: int)

String
	

get_environment(variable: String) const

String
	

get_executable_path() const

PackedStringArray
	

get_granted_permissions() const

String
	

get_keycode_string(code: Key) const

String
	

get_locale() const

String
	

get_locale_language() const

int
	

get_main_thread_id() const

Dictionary
	

get_memory_info() const

String
	

get_model_name() const

String
	

get_name() const

int
	

get_process_exit_code(pid: int) const

int
	

get_process_id() const

int
	

get_processor_count() const

String
	

get_processor_name() const

PackedStringArray
	

get_restart_on_exit_arguments() const

int
	

get_static_memory_peak_usage() const

int
	

get_static_memory_usage() const

StdHandleType
	

get_stderr_type() const

StdHandleType
	

get_stdin_type() const

StdHandleType
	

get_stdout_type() const

String
	

get_system_ca_certificates()

String
	

get_system_dir(dir: SystemDir, shared_storage: bool = true) const

String
	

get_system_font_path(font_name: String, weight: int = 400, stretch: int = 100, italic: bool = false) const

PackedStringArray
	

get_system_font_path_for_text(font_name: String, text: String, locale: String = "", script: String = "", weight: int = 400, stretch: int = 100, italic: bool = false) const

PackedStringArray
	

get_system_fonts() const

String
	

get_temp_dir() const

int
	

get_thread_caller_id() const

String
	

get_unique_id() const

String
	

get_user_data_dir() const

String
	

get_version() const

String
	

get_version_alias() const

PackedStringArray
	

get_video_adapter_driver_info() const

bool
	

has_environment(variable: String) const

bool
	

has_feature(tag_name: String) const

bool
	

is_debug_build() const

bool
	

is_keycode_unicode(code: int) const

bool
	

is_process_running(pid: int) const

bool
	

is_restart_on_exit_set() const

bool
	

is_sandboxed() const

bool
	

is_stdout_verbose() const

bool
	

is_userfs_persistent() const

Error
	

kill(pid: int)

Error
	

move_to_trash(path: String) const

void
	

open_midi_inputs()

PackedByteArray
	

read_buffer_from_stdin(buffer_size: int)

String
	

read_string_from_stdin(buffer_size: int)

bool
	

request_permission(name: String)

bool
	

request_permissions()

void
	

revoke_granted_permissions()

void
	

set_environment(variable: String, value: String) const

void
	

set_restart_on_exit(restart: bool, arguments: PackedStringArray = PackedStringArray())

Error
	

set_thread_name(name: String)

void
	

set_use_file_access_save_and_swap(enabled: bool)

Error
	

shell_open(uri: String)

Error
	

shell_show_in_file_manager(file_or_dir_path: String, open_folder: bool = true)

void
	

unset_environment(variable: String) const
Enumerations

enum RenderingDriver:

RenderingDriver RENDERING_DRIVER_VULKAN = 0

The Vulkan rendering driver. It requires Vulkan 1.0 support and automatically uses features from Vulkan 1.1 and 1.2 if available.

RenderingDriver RENDERING_DRIVER_OPENGL3 = 1

The OpenGL 3 rendering driver. It uses OpenGL 3.3 Core Profile on desktop platforms, OpenGL ES 3.0 on mobile devices, and WebGL 2.0 on Web.

RenderingDriver RENDERING_DRIVER_D3D12 = 2

The Direct3D 12 rendering driver.

RenderingDriver RENDERING_DRIVER_METAL = 3

The Metal rendering driver.

enum SystemDir:

SystemDir SYSTEM_DIR_DESKTOP = 0

Refers to the Desktop directory path.

SystemDir SYSTEM_DIR_DCIM = 1

Refers to the DCIM (Digital Camera Images) directory path.

SystemDir SYSTEM_DIR_DOCUMENTS = 2

Refers to the Documents directory path.

SystemDir SYSTEM_DIR_DOWNLOADS = 3

Refers to the Downloads directory path.

SystemDir SYSTEM_DIR_MOVIES = 4

Refers to the Movies (or Videos) directory path.

SystemDir SYSTEM_DIR_MUSIC = 5

Refers to the Music directory path.

SystemDir SYSTEM_DIR_PICTURES = 6

Refers to the Pictures directory path.

SystemDir SYSTEM_DIR_RINGTONES = 7

Refers to the Ringtones directory path.

enum StdHandleType:

StdHandleType STD_HANDLE_INVALID = 0

Standard I/O device is invalid. No data can be received from or sent to these standard I/O devices.

StdHandleType STD_HANDLE_CONSOLE = 1

Standard I/O device is a console. This typically occurs when Godot is run from a terminal with no redirection. This is also used for all standard I/O devices when running Godot from the editor, at least on desktop platforms.

StdHandleType STD_HANDLE_FILE = 2

Standard I/O device is a regular file. This typically occurs with redirection from a terminal, e.g. godot > stdout.txt, godot < stdin.txt or godot > stdout_stderr.txt 2>&1.

StdHandleType STD_HANDLE_PIPE = 3

Standard I/O device is a FIFO/pipe. This typically occurs with pipe usage from a terminal, e.g. echo "Hello" | godot.

StdHandleType STD_HANDLE_UNKNOWN = 4

Standard I/O device type is unknown.
Property Descriptions

bool delta_smoothing = true

    void set_delta_smoothing(value: bool)

    bool is_delta_smoothing_enabled()

If true, the engine filters the time delta measured between each frame, and attempts to compensate for random variation. This only works on systems where V-Sync is active.

Note: On start-up, this is the same as ProjectSettings.application/run/delta_smoothing.

bool low_processor_usage_mode = false

    void set_low_processor_usage_mode(value: bool)

    bool is_in_low_processor_usage_mode()

If true, the engine optimizes for low processor usage by only refreshing the screen if needed. Can improve battery consumption on mobile.

Note: On start-up, this is the same as ProjectSettings.application/run/low_processor_mode.

int low_processor_usage_mode_sleep_usec = 6900

    void set_low_processor_usage_mode_sleep_usec(value: int)

    int get_low_processor_usage_mode_sleep_usec()

The amount of sleeping between frames when the low-processor usage mode is enabled, in microseconds. Higher values will result in lower CPU usage. See also low_processor_usage_mode.

Note: On start-up, this is the same as ProjectSettings.application/run/low_processor_mode_sleep_usec.
Method Descriptions

void alert(text: String, title: String = "Alert!")

Displays a modal dialog box using the host platform's implementation. The engine execution is blocked until the dialog is closed.

void close_midi_inputs()

Shuts down the system MIDI driver. Godot will no longer receive InputEventMIDI. See also open_midi_inputs() and get_connected_midi_inputs().

Note: This method is implemented on Linux, macOS, Windows, and Web.

void crash(message: String)

Crashes the engine (or the editor if called within a @tool script). See also kill().

Note: This method should only be used for testing the system's crash handler, not for any other purpose. For general error reporting, use (in order of preference) @GDScript.assert(), @GlobalScope.push_error(), or alert().

int create_instance(arguments: PackedStringArray)

Creates a new instance of Godot that runs independently. The arguments are used in the given order and separated by a space.

If the process is successfully created, this method returns the new process' ID, which you can use to monitor the process (and potentially terminate it with kill()). If the process cannot be created, this method returns -1.

See create_process() if you wish to run a different process.

Note: This method is implemented on Android, Linux, macOS and Windows.

int create_process(path: String, arguments: PackedStringArray, open_console: bool = false)

Creates a new process that runs independently of Godot. It will not terminate when Godot terminates. The path specified in path must exist and be an executable file or macOS .app bundle. The path is resolved based on the current platform. The arguments are used in the given order and separated by a space.

On Windows, if open_console is true and the process is a console app, a new terminal window will be opened.

If the process is successfully created, this method returns its process ID, which you can use to monitor the process (and potentially terminate it with kill()). Otherwise, this method returns -1.

Example: Run another instance of the project:

var pid = OS.create_process(OS.get_executable_path(), [])

See execute() if you wish to run an external command and retrieve the results.

Note: This method is implemented on Android, Linux, macOS, and Windows.

Note: On macOS, sandboxed applications are limited to run only embedded helper executables, specified during export or system .app bundle, system .app bundles will ignore arguments.

void delay_msec(msec: int) const

Delays execution of the current thread by msec milliseconds. msec must be greater than or equal to 0. Otherwise, delay_msec() does nothing and prints an error message.

Note: delay_msec() is a blocking way to delay code execution. To delay code execution in a non-blocking way, you may use SceneTree.create_timer(). Awaiting with SceneTreeTimer delays the execution of code placed below the await without affecting the rest of the project (or editor, for EditorPlugins and EditorScripts).

Note: When delay_msec() is called on the main thread, it will freeze the project and will prevent it from redrawing and registering input until the delay has passed. When using delay_msec() as part of an EditorPlugin or EditorScript, it will freeze the editor but won't freeze the project if it is currently running (since the project is an independent child process).

void delay_usec(usec: int) const

Delays execution of the current thread by usec microseconds. usec must be greater than or equal to 0. Otherwise, delay_usec() does nothing and prints an error message.

Note: delay_usec() is a blocking way to delay code execution. To delay code execution in a non-blocking way, you may use SceneTree.create_timer(). Awaiting with a SceneTreeTimer delays the execution of code placed below the await without affecting the rest of the project (or editor, for EditorPlugins and EditorScripts).

Note: When delay_usec() is called on the main thread, it will freeze the project and will prevent it from redrawing and registering input until the delay has passed. When using delay_usec() as part of an EditorPlugin or EditorScript, it will freeze the editor but won't freeze the project if it is currently running (since the project is an independent child process).

int execute(path: String, arguments: PackedStringArray, output: Array = [], read_stderr: bool = false, open_console: bool = false)

Executes the given process in a blocking way. The file specified in path must exist and be executable. The system path resolution will be used. The arguments are used in the given order, separated by spaces, and wrapped in quotes.

If an output array is provided, the complete shell output of the process is appended to output as a single String element. If read_stderr is true, the output to the standard error stream is also appended to the array.

On Windows, if open_console is true and the process is a console app, a new terminal window is opened.

This method returns the exit code of the command, or -1 if the process fails to execute.

Note: The main thread will be blocked until the executed command terminates. Use Thread to create a separate thread that will not block the main thread, or use create_process() to create a completely independent process.

For example, to retrieve a list of the working directory's contents:

var output = []
var exit_code = OS.execute("ls", ["-l", "/tmp"], output)

If you wish to access a shell built-in or execute a composite command, a platform-specific shell can be invoked. For example:

var output = []
OS.execute("CMD.exe", ["/C", "cd %TEMP% && dir"], output)

Note: This method is implemented on Android, Linux, macOS, and Windows.

Note: To execute a Windows command interpreter built-in command, specify cmd.exe in path, /c as the first argument, and the desired command as the second argument.

Note: To execute a PowerShell built-in command, specify powershell.exe in path, -Command as the first argument, and the desired command as the second argument.

Note: To execute a Unix shell built-in command, specify shell executable name in path, -c as the first argument, and the desired command as the second argument.

Note: On macOS, sandboxed applications are limited to run only embedded helper executables, specified during export.

Note: On Android, system commands such as dumpsys can only be run on a rooted device.

Dictionary execute_with_pipe(path: String, arguments: PackedStringArray, blocking: bool = true)

Creates a new process that runs independently of Godot with redirected IO. It will not terminate when Godot terminates. The path specified in path must exist and be an executable file or macOS .app bundle. The path is resolved based on the current platform. The arguments are used in the given order and separated by a space.

If blocking is false, created pipes work in non-blocking mode, i.e. read and write operations will return immediately. Use FileAccess.get_error() to check if the last read/write operation was successful.

If the process cannot be created, this method returns an empty Dictionary. Otherwise, this method returns a Dictionary with the following keys:

    "stdio" - FileAccess to access the process stdin and stdout pipes (read/write).

    "stderr" - FileAccess to access the process stderr pipe (read only).

    "pid" - Process ID as an int, which you can use to monitor the process (and potentially terminate it with kill()).

Note: This method is implemented on Android, Linux, macOS, and Windows.

Note: To execute a Windows command interpreter built-in command, specify cmd.exe in path, /c as the first argument, and the desired command as the second argument.

Note: To execute a PowerShell built-in command, specify powershell.exe in path, -Command as the first argument, and the desired command as the second argument.

Note: To execute a Unix shell built-in command, specify shell executable name in path, -c as the first argument, and the desired command as the second argument.

Note: On macOS, sandboxed applications are limited to run only embedded helper executables, specified during export or system .app bundle, system .app bundles will ignore arguments.

Key find_keycode_from_string(string: String) const

Finds the keycode for the given string. The returned values are equivalent to the Key constants.

print(OS.find_keycode_from_string("C"))         # Prints 67 (KEY_C)
print(OS.find_keycode_from_string("Escape"))    # Prints 4194305 (KEY_ESCAPE)
print(OS.find_keycode_from_string("Shift+Tab")) # Prints 37748738 (KEY_MASK_SHIFT | KEY_TAB)
print(OS.find_keycode_from_string("Unknown"))   # Prints 0 (KEY_NONE)

See also get_keycode_string().

String get_cache_dir() const

Returns the global cache data directory according to the operating system's standards.

On the Linux/BSD platform, this path can be overridden by setting the XDG_CACHE_HOME environment variable before starting the project. See File paths in Godot projects in the documentation for more information. See also get_config_dir() and get_data_dir().

Not to be confused with get_user_data_dir(), which returns the project-specific user data path.

PackedStringArray get_cmdline_args()

Returns the command-line arguments passed to the engine.

Command-line arguments can be written in any form, including both --key value and --key=value forms so they can be properly parsed, as long as custom command-line arguments do not conflict with engine arguments.

You can also incorporate environment variables using the get_environment() method.

You can set ProjectSettings.editor/run/main_run_args to define command-line arguments to be passed by the editor when running the project.

Example: Parse command-line arguments into a Dictionary using the --key=value form for arguments:

var arguments = {}
for argument in OS.get_cmdline_args():
	if argument.contains("="):
		var key_value = argument.split("=")
		arguments[key_value[0].trim_prefix("--")] = key_value[1]
	else:
		# Options without an argument will be present in the dictionary,
		# with the value set to an empty string.
		arguments[argument.trim_prefix("--")] = ""

Note: Passing custom user arguments directly is not recommended, as the engine may discard or modify them. Instead, pass the standard UNIX double dash (--) and then the custom arguments, which the engine will ignore by design. These can be read via get_cmdline_user_args().

PackedStringArray get_cmdline_user_args()

Returns the command-line user arguments passed to the engine. User arguments are ignored by the engine and reserved for the user. They are passed after the double dash -- argument. ++ may be used when -- is intercepted by another program (such as startx).

# Godot has been executed with the following command:
# godot --fullscreen -- --level=2 --hardcore

OS.get_cmdline_args()      # Returns ["--fullscreen", "--level=2", "--hardcore"]
OS.get_cmdline_user_args() # Returns ["--level=2", "--hardcore"]

To get all passed arguments, use get_cmdline_args().

String get_config_dir() const

Returns the global user configuration directory according to the operating system's standards.

On the Linux/BSD platform, this path can be overridden by setting the XDG_CONFIG_HOME environment variable before starting the project. See File paths in Godot projects in the documentation for more information. See also get_cache_dir() and get_data_dir().

Not to be confused with get_user_data_dir(), which returns the project-specific user data path.

PackedStringArray get_connected_midi_inputs()

Returns an array of connected MIDI device names, if they exist. Returns an empty array if the system MIDI driver has not previously been initialized with open_midi_inputs(). See also close_midi_inputs().

Note: This method is implemented on Linux, macOS, Windows, and Web.

Note: On the Web platform, Web MIDI needs to be supported by the browser. For the time being, it is currently supported by all major browsers, except Safari.

Note: On the Web platform, using MIDI input requires a browser permission to be granted first. This permission request is performed when calling open_midi_inputs(). The browser will refrain from processing MIDI input until the user accepts the permission request.

String get_data_dir() const

Returns the global user data directory according to the operating system's standards.

On the Linux/BSD platform, this path can be overridden by setting the XDG_DATA_HOME environment variable before starting the project. See File paths in Godot projects in the documentation for more information. See also get_cache_dir() and get_config_dir().

Not to be confused with get_user_data_dir(), which returns the project-specific user data path.

String get_distribution_name() const

Returns the name of the distribution for Linux and BSD platforms (e.g. "Ubuntu", "Manjaro", "OpenBSD", etc.).

Returns the same value as get_name() for stock Android ROMs, but attempts to return the custom ROM name for popular Android derivatives such as "LineageOS".

Returns the same value as get_name() for other platforms.

Note: This method is not supported on the Web platform. It returns an empty string.

PackedByteArray get_entropy(size: int)

Generates a PackedByteArray of cryptographically secure random bytes with given size.

Note: Generating large quantities of bytes using this method can result in locking and entropy of lower quality on most platforms. Using Crypto.generate_random_bytes() is preferred in most cases.

String get_environment(variable: String) const

Returns the value of the given environment variable, or an empty string if variable doesn't exist.

Note: Double-check the casing of variable. Environment variable names are case-sensitive on all platforms except Windows.

Note: On macOS, applications do not have access to shell environment variables.

String get_executable_path() const

Returns the file path to the current engine executable.

Note: On macOS, if you want to launch another instance of Godot, always use create_instance() instead of relying on the executable path.

PackedStringArray get_granted_permissions() const

On Android devices: Returns the list of dangerous permissions that have been granted.

On macOS: Returns the list of user selected folders accessible to the application (sandboxed applications only). Use the native file dialog to request folder access permission.

String get_keycode_string(code: Key) const

Returns the given keycode as a String.

print(OS.get_keycode_string(KEY_C))                    # Prints "C"
print(OS.get_keycode_string(KEY_ESCAPE))               # Prints "Escape"
print(OS.get_keycode_string(KEY_MASK_SHIFT | KEY_TAB)) # Prints "Shift+Tab"

See also find_keycode_from_string(), InputEventKey.keycode, and InputEventKey.get_keycode_with_modifiers().

String get_locale() const

Returns the host OS locale as a String of the form language_Script_COUNTRY_VARIANT@extra. Every substring after language is optional and may not exist.

    language - 2 or 3-letter language code, in lower case.

    Script - 4-letter script code, in title case.

    COUNTRY - 2 or 3-letter country code, in upper case.

    VARIANT - language variant, region and sort order. The variant can have any number of underscored keywords.

    extra - semicolon separated list of additional key words. This may include currency, calendar, sort order and numbering system information.

If you want only the language code and not the fully specified locale from the OS, you can use get_locale_language().

String get_locale_language() const

Returns the host OS locale's 2 or 3-letter language code as a string which should be consistent on all platforms. This is equivalent to extracting the language part of the get_locale() string.

This can be used to narrow down fully specified locale strings to only the "common" language code, when you don't need the additional information about country code or variants. For example, for a French Canadian user with fr_CA locale, this would return fr.

int get_main_thread_id() const

Returns the ID of the main thread. See get_thread_caller_id().

Note: Thread IDs are not deterministic and may be reused across application restarts.

Dictionary get_memory_info() const

Returns a Dictionary containing information about the current memory with the following entries:

    "physical" - total amount of usable physical memory in bytes. This value can be slightly less than the actual physical memory amount, since it does not include memory reserved by the kernel and devices.

    "free" - amount of physical memory, that can be immediately allocated without disk access or other costly operations, in bytes. The process might be able to allocate more physical memory, but this action will require moving inactive pages to disk, which can be expensive.

    "available" - amount of memory that can be allocated without extending the swap file(s), in bytes. This value includes both physical memory and swap.

    "stack" - size of the current thread stack in bytes.

Note: Each entry's value may be -1 if it is unknown.

String get_model_name() const

Returns the model name of the current device.

Note: This method is implemented on Android, iOS, macOS, and Windows. Returns "GenericDevice" on unsupported platforms.

String get_name() const

Returns the name of the host platform.

    On Windows, this is "Windows".

    On macOS, this is "macOS".

    On Linux-based operating systems, this is "Linux".

    On BSD-based operating systems, this is "FreeBSD", "NetBSD", "OpenBSD", or "BSD" as a fallback.

    On Android, this is "Android".

    On iOS, this is "iOS".

    On Web, this is "Web".

Note: Custom builds of the engine may support additional platforms, such as consoles, possibly returning other names.

match OS.get_name():
	"Windows":
		print("Welcome to Windows!")
	"macOS":
		print("Welcome to macOS!")
	"Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD":
		print("Welcome to Linux/BSD!")
	"Android":
		print("Welcome to Android!")
	"iOS":
		print("Welcome to iOS!")
	"Web":
		print("Welcome to the Web!")

Note: On Web platforms, it is still possible to determine the host platform's OS with feature tags. See has_feature().

int get_process_exit_code(pid: int) const

Returns the exit code of a spawned process once it has finished running (see is_process_running()).

Returns -1 if the pid is not a PID of a spawned child process, the process is still running, or the method is not implemented for the current platform.

Note: Returns -1 if the pid is a macOS bundled app process.

Note: This method is implemented on Android, Linux, macOS and Windows.

int get_process_id() const

Returns the number used by the host machine to uniquely identify this application.

Note: This method is implemented on Android, iOS, Linux, macOS, and Windows.

int get_processor_count() const

Returns the number of logical CPU cores available on the host machine. On CPUs with HyperThreading enabled, this number will be greater than the number of physical CPU cores.

String get_processor_name() const

Returns the full name of the CPU model on the host machine (e.g. "Intel(R) Core(TM) i7-6700K CPU @ 4.00GHz").

Note: This method is only implemented on Windows, macOS, Linux and iOS. On Android and Web, get_processor_name() returns an empty string.

PackedStringArray get_restart_on_exit_arguments() const

Returns the list of command line arguments that will be used when the project automatically restarts using set_restart_on_exit(). See also is_restart_on_exit_set().

int get_static_memory_peak_usage() const

Returns the maximum amount of static memory used. Only works in debug builds.

int get_static_memory_usage() const

Returns the amount of static memory being used by the program in bytes. Only works in debug builds.

StdHandleType get_stderr_type() const

Returns type of the standard error device.

StdHandleType get_stdin_type() const

Returns type of the standard input device.

StdHandleType get_stdout_type() const

Returns type of the standard output device.

String get_system_ca_certificates()

Returns the list of certification authorities trusted by the operating system as a string of concatenated certificates in PEM format.

String get_system_dir(dir: SystemDir, shared_storage: bool = true) const

Returns the path to commonly used folders across different platforms, as defined by dir. See the SystemDir constants for available locations.

Note: This method is implemented on Android, Linux, macOS and Windows.

Note: Shared storage is implemented on Android and allows to differentiate between app specific and shared directories, if shared_storage is true. Shared directories have additional restrictions on Android.

String get_system_font_path(font_name: String, weight: int = 400, stretch: int = 100, italic: bool = false) const

Returns the path to the system font file with font_name and style. Returns an empty string if no matching fonts found.

The following aliases can be used to request default fonts: "sans-serif", "serif", "monospace", "cursive", and "fantasy".

Note: Returned font might have different style if the requested style is not available.

Note: This method is implemented on Android, iOS, Linux, macOS and Windows.

PackedStringArray get_system_font_path_for_text(font_name: String, text: String, locale: String = "", script: String = "", weight: int = 400, stretch: int = 100, italic: bool = false) const

Returns an array of the system substitute font file paths, which are similar to the font with font_name and style for the specified text, locale, and script. Returns an empty array if no matching fonts found.

The following aliases can be used to request default fonts: "sans-serif", "serif", "monospace", "cursive", and "fantasy".

Note: Depending on OS, it's not guaranteed that any of the returned fonts will be suitable for rendering specified text. Fonts should be loaded and checked in the order they are returned, and the first suitable one used.

Note: Returned fonts might have different style if the requested style is not available or belong to a different font family.

Note: This method is implemented on Android, iOS, Linux, macOS and Windows.

PackedStringArray get_system_fonts() const

Returns the list of font family names available.

Note: This method is implemented on Android, iOS, Linux, macOS and Windows.

String get_temp_dir() const

Returns the global temporary data directory according to the operating system's standards.

int get_thread_caller_id() const

Returns the ID of the current thread. This can be used in logs to ease debugging of multi-threaded applications.

Note: Thread IDs are not deterministic and may be reused across application restarts.

String get_unique_id() const

Returns a string that is unique to the device.

Note: This string may change without notice if the user reinstalls their operating system, upgrades it, or modifies their hardware. This means it should generally not be used to encrypt persistent data, as the data saved before an unexpected ID change would become inaccessible. The returned string may also be falsified using external programs, so do not rely on the string returned by this method for security purposes.

Note: On Web, returns an empty string and generates an error, as this method cannot be implemented for security reasons.

String get_user_data_dir() const

Returns the absolute directory path where user data is written (the user:// directory in Godot). The path depends on the project name and ProjectSettings.application/config/use_custom_user_dir.

    On Windows, this is %AppData%\Godot\app_userdata\[project_name], or %AppData%\[custom_name] if use_custom_user_dir is set. %AppData% expands to %UserProfile%\AppData\Roaming.

    On macOS, this is ~/Library/Application Support/Godot/app_userdata/[project_name], or ~/Library/Application Support/[custom_name] if use_custom_user_dir is set.

    On Linux and BSD, this is ~/.local/share/godot/app_userdata/[project_name], or ~/.local/share/[custom_name] if use_custom_user_dir is set.

    On Android and iOS, this is a sandboxed directory in either internal or external storage, depending on the user's configuration.

    On Web, this is a virtual directory managed by the browser.

If the project name is empty, [project_name] falls back to [unnamed project].

Not to be confused with get_data_dir(), which returns the global (non-project-specific) user home directory.

String get_version() const

Returns the exact production and build version of the operating system. This is different from the branded version used in marketing. This helps to distinguish between different releases of operating systems, including minor versions, and insider and custom builds.

    For Windows, the major and minor version are returned, as well as the build number. For example, the returned string may look like 10.0.9926 for a build of Windows 10, and it may look like 6.1.7601 for a build of Windows 7 SP1.

    For rolling distributions, such as Arch Linux, an empty string is returned.

    For macOS and iOS, the major and minor version are returned, as well as the patch number.

    For Android, the SDK version and the incremental build number are returned. If it's a custom ROM, it attempts to return its version instead.

Note: This method is not supported on the Web platform. It returns an empty string.

String get_version_alias() const

Returns the branded version used in marketing, followed by the build number (on Windows) or the version number (on macOS). Examples include 11 (build 22000) and Sequoia (15.0.0). This value can then be appended to get_name() to get a full, human-readable operating system name and version combination for the operating system. Windows feature updates such as 24H2 are not contained in the resulting string, but Windows Server is recognized as such (e.g. 2025 (build 26100) for Windows Server 2025).

Note: This method is only supported on Windows and macOS. On other operating systems, it returns the same value as get_version().

PackedStringArray get_video_adapter_driver_info() const

Returns the video adapter driver name and version for the user's currently active graphics card, as a PackedStringArray. See also RenderingServer.get_video_adapter_api_version().

The first element holds the driver name, such as nvidia, amdgpu, etc.

The second element holds the driver version. For example, on the nvidia driver on a Linux/BSD platform, the version is in the format 510.85.02. For Windows, the driver's format is 31.0.15.1659.

Note: This method is only supported on Linux/BSD and Windows when not running in headless mode. On other platforms, it returns an empty array.

bool has_environment(variable: String) const

Returns true if the environment variable with the name variable exists.

Note: Double-check the casing of variable. Environment variable names are case-sensitive on all platforms except Windows.

bool has_feature(tag_name: String) const

Returns true if the feature for the given feature tag is supported in the currently running instance, depending on the platform, build, etc. Can be used to check whether you're currently running a debug build, on a certain platform or arch, etc. Refer to the Feature Tags documentation for more details.

Note: Tag names are case-sensitive.

Note: On the Web platform, one of the following additional tags is defined to indicate the host platform: web_android, web_ios, web_linuxbsd, web_macos, or web_windows.

bool is_debug_build() const

Returns true if the Godot binary used to run the project is a debug export template, or when running in the editor.

Returns false if the Godot binary used to run the project is a release export template.

Note: To check whether the Godot binary used to run the project is an export template (debug or release), use OS.has_feature("template") instead.

bool is_keycode_unicode(code: int) const

Returns true if the input keycode corresponds to a Unicode character. For a list of codes, see the Key constants.

print(OS.is_keycode_unicode(KEY_G))      # Prints true
print(OS.is_keycode_unicode(KEY_KP_4))   # Prints true
print(OS.is_keycode_unicode(KEY_TAB))    # Prints false
print(OS.is_keycode_unicode(KEY_ESCAPE)) # Prints false

bool is_process_running(pid: int) const

Returns true if the child process ID (pid) is still running or false if it has terminated. pid must be a valid ID generated from create_process().

Note: This method is implemented on Android, iOS, Linux, macOS, and Windows.

bool is_restart_on_exit_set() const

Returns true if the project will automatically restart when it exits for any reason, false otherwise. See also set_restart_on_exit() and get_restart_on_exit_arguments().

bool is_sandboxed() const

Returns true if the application is running in the sandbox.

Note: This method is only implemented on macOS and Linux.

bool is_stdout_verbose() const

Returns true if the engine was executed with the --verbose or -v command line argument, or if ProjectSettings.debug/settings/stdout/verbose_stdout is true. See also @GlobalScope.print_verbose().

bool is_userfs_persistent() const

Returns true if the user:// file system is persistent, that is, its state is the same after a player quits and starts the game again. Relevant to the Web platform, where this persistence may be unavailable.

Error kill(pid: int)

Kill (terminate) the process identified by the given process ID (pid), such as the ID returned by execute() in non-blocking mode. See also crash().

Note: This method can also be used to kill processes that were not spawned by the engine.

Note: This method is implemented on Android, iOS, Linux, macOS and Windows.

Error move_to_trash(path: String) const

Moves the file or directory at the given path to the system's recycle bin. See also DirAccess.remove().

The method takes only global paths, so you may need to use ProjectSettings.globalize_path(). Do not use it for files in res:// as it will not work in exported projects.

Returns @GlobalScope.FAILED if the file or directory cannot be found, or the system does not support this method.

var file_to_remove = "user://slot1.save"
OS.move_to_trash(ProjectSettings.globalize_path(file_to_remove))

Note: This method is implemented on Android, Linux, macOS and Windows.

Note: If the user has disabled the recycle bin on their system, the file will be permanently deleted instead.

void open_midi_inputs()

Initializes the singleton for the system MIDI driver, allowing Godot to receive InputEventMIDI. See also get_connected_midi_inputs() and close_midi_inputs().

Note: This method is implemented on Linux, macOS, Windows, and Web.

Note: On the Web platform, Web MIDI needs to be supported by the browser. For the time being, it is currently supported by all major browsers, except Safari.

Note: On the Web platform, using MIDI input requires a browser permission to be granted first. This permission request is performed when calling open_midi_inputs(). The browser will refrain from processing MIDI input until the user accepts the permission request.

PackedByteArray read_buffer_from_stdin(buffer_size: int)

Reads a user input as raw data from the standard input. This operation can be blocking, which causes the window to freeze if read_string_from_stdin() is called on the main thread.

    If standard input is console, this method will block until the program receives a line break in standard input (usually by the user pressing Enter).

    If standard input is pipe, this method will block until a specific amount of data is read or pipe is closed.

    If standard input is a file, this method will read a specific amount of data (or less if end-of-file is reached) and return immediately.

Note: This method is implemented on Linux, macOS, and Windows.

Note: On exported Windows builds, run the console wrapper executable to access the terminal. If standard input is console, calling this method without console wrapped will freeze permanently. If standard input is pipe or file, it can be used without console wrapper. If you need a single executable with full console support, use a custom build compiled with the windows_subsystem=console flag.

String read_string_from_stdin(buffer_size: int)

Reads a user input as a UTF-8 encoded string from the standard input. This operation can be blocking, which causes the window to freeze if read_string_from_stdin() is called on the main thread.

    If standard input is console, this method will block until the program receives a line break in standard input (usually by the user pressing Enter).

    If standard input is pipe, this method will block until a specific amount of data is read or pipe is closed.

    If standard input is a file, this method will read a specific amount of data (or less if end-of-file is reached) and return immediately.

Note: This method automatically replaces \r\n line breaks with \n and removes them from the end of the string. Use read_buffer_from_stdin() to read the unprocessed data.

Note: This method is implemented on Linux, macOS, and Windows.

Note: On exported Windows builds, run the console wrapper executable to access the terminal. If standard input is console, calling this method without console wrapped will freeze permanently. If standard input is pipe or file, it can be used without console wrapper. If you need a single executable with full console support, use a custom build compiled with the windows_subsystem=console flag.

bool request_permission(name: String)

Requests permission from the OS for the given name. Returns true if the permission has already been granted. See also MainLoop.on_request_permissions_result.

The name must be the full permission name. For example:

    OS.request_permission("android.permission.READ_EXTERNAL_STORAGE")

    OS.request_permission("android.permission.POST_NOTIFICATIONS")

Note: Permission must be checked during export.

Note: This method is only implemented on Android.

bool request_permissions()

Requests dangerous permissions from the OS. Returns true if permissions have already been granted. See also MainLoop.on_request_permissions_result.

Note: Permissions must be checked during export.

Note: This method is only implemented on Android. Normal permissions are automatically granted at install time in Android applications.

void revoke_granted_permissions()

On macOS (sandboxed applications only), this function clears list of user selected folders accessible to the application.

void set_environment(variable: String, value: String) const

Sets the value of the environment variable variable to value. The environment variable will be set for the Godot process and any process executed with execute() after running set_environment(). The environment variable will not persist to processes run after the Godot process was terminated.

Note: Environment variable names are case-sensitive on all platforms except Windows. The variable name cannot be empty or include the = character. On Windows, there is a 32767 characters limit for the combined length of variable, value, and the = and null terminator characters that will be registered in the environment block.

void set_restart_on_exit(restart: bool, arguments: PackedStringArray = PackedStringArray())

If restart is true, restarts the project automatically when it is exited with SceneTree.quit() or Node.NOTIFICATION_WM_CLOSE_REQUEST. Command-line arguments can be supplied. To restart the project with the same command line arguments as originally used to run the project, pass get_cmdline_args() as the value for arguments.

This method can be used to apply setting changes that require a restart. See also is_restart_on_exit_set() and get_restart_on_exit_arguments().

Note: This method is only effective on desktop platforms, and only when the project isn't started from the editor. It will have no effect on mobile and Web platforms, or when the project is started from the editor.

Note: If the project process crashes or is killed by the user (by sending SIGKILL instead of the usual SIGTERM), the project won't restart automatically.

Error set_thread_name(name: String)

Assigns the given name to the current thread. Returns @GlobalScope.ERR_UNAVAILABLE if unavailable on the current platform.

void set_use_file_access_save_and_swap(enabled: bool)

If enabled is true, when opening a file for writing, a temporary file is used in its place. When closed, it is automatically applied to the target file.

This can useful when files may be opened by other applications, such as antiviruses, text editors, or even the Godot editor itself.

Error shell_open(uri: String)

Requests the OS to open a resource identified by uri with the most appropriate program. For example:

    OS.shell_open("C:\\Users\\name\\Downloads") on Windows opens the file explorer at the user's Downloads folder.

    OS.shell_open("C:/Users/name/Downloads") also works on Windows and opens the file explorer at the user's Downloads folder.

    OS.shell_open("https://godotengine.org") opens the default web browser on the official Godot website.

    OS.shell_open("mailto:example@example.com") opens the default email client with the "To" field set to example@example.com. See RFC 2368 - The [code]mailto[/code] URL scheme for a list of fields that can be added.

Use ProjectSettings.globalize_path() to convert a res:// or user:// project path into a system path for use with this method.

Note: Use String.uri_encode() to encode characters within URLs in a URL-safe, portable way. This is especially required for line breaks. Otherwise, shell_open() may not work correctly in a project exported to the Web platform.

Note: This method is implemented on Android, iOS, Web, Linux, macOS and Windows.

Error shell_show_in_file_manager(file_or_dir_path: String, open_folder: bool = true)

Requests the OS to open the file manager, navigate to the given file_or_dir_path and select the target file or folder.

If open_folder is true and file_or_dir_path is a valid directory path, the OS will open the file manager and navigate to the target folder without selecting anything.

Use ProjectSettings.globalize_path() to convert a res:// or user:// project path into a system path to use with this method.

Note: This method is currently only implemented on Windows and macOS. On other platforms, it will fallback to shell_open() with a directory path of file_or_dir_path prefixed with file://.

void unset_environment(variable: String) const

Removes the given environment variable from the current environment, if it exists. The variable name cannot be empty or include the = character. The environment variable will be removed for the Godot process and any process executed with execute() after running unset_environment(). The removal of the environment variable will not persist to processes run after the Godot process was terminated.

Note: Environment variable names are case-sensitive on all platforms except Windows.