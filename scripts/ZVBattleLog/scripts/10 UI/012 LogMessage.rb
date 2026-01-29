module ZVBattleLogUI
  # UI element showing the first line of a log message
  class LogMessage < UI::SpriteStack
    # If this log message is currently selected
    # @return [Boolean]
    attr_accessor :selected

    # @param viewport [Viewport]
    # @param index [Integer]
    def initialize(viewport, index)
      x_base, y_base = base_position
      x_off, y_off = button_offset
      super(viewport, x_base + x_off * index, y_base + y_off * index)
      create_sprites
      create_text
      create_animation
      self.selected = false
    end

    # Update the visibility of the selector
    def update_icon_visibility
      @selector.visible = selected
      @truncator_animation.update if @truncator.visible
    end

    # Set the log message to display
    # @param entry [ZVBattleLog::LogEntryBase]
    def text=(entry)
      message, truncated = adjust_message(entry&.message.to_s)
      @text.text = message
      @truncator.visible = truncated
      @text.load_color(entry&.message_color || color_id)
    end

    private

    def create_sprites
      @selector = add_sprite(*selector_position, selector_filename)
      @truncator = add_sprite(*truncator_position, truncator_filename)
      @selector.visible = false
      @truncator.visible = false
    end

    def create_text
      @text = with_font(font_id) do
        add_text(*text_position, *text_dimensions, nil.to_s, color: color_id, type: UI::SymText)
      end
    end

    def create_animation
      ya = Yuki::Animation
      @truncator_animation = ya.timed_loop_animation(
        1, [
          ya.send_command_to(@truncator, :opacity=, 255),
          ya.wait(0.5),
          ya.send_command_to(@truncator, :opacity=, 0)
        ]
      ).start
    end

    # Get a version of the message that complies with the font and is possibly truncated to fit in 1 line
    # @param message [String]
    # @return [Array<String, Boolean>] Adjusted message, and whether it was truncated
    def adjust_message(message)
      message = message.dup
      replace_unsupported_chars(message)
      return message, false if @text.text_width(message) <= max_text_width

      text_width = ->(n) { @text.text_width(message[0, n]) }
      nchars = max_text_width / 5
      nchars -= 1 until text_width.call(nchars) <= max_text_width
      nchars += 1 until text_width.call(nchars) > max_text_width
      return message[0, nchars - 1], true
    end

    # Replace characters that the font (Power Greeb Small) doesn't support
    # @param message [String]
    def replace_unsupported_chars(message)
      message.gsub!('’', '\'')
      message.gsub!('…', '...')
    end

    # Base top-left coordinates of the UI element
    # @return [Array<Integer>]
    def base_position = [8, 41]

    # Offset between each of these UI elements
    # @return [Array<Integer>]
    def button_offset = [0, 16]

    # @return [Array<Integer>]
    def text_position = [5, 7]

    # @return [Array<Integer>]
    def text_dimensions = [284, 8]

    # @return [Integer]
    def color_id = 0

    # @return [Integer]
    def font_id = 20

    # @return [String]
    def selector_filename = Configs.zv_battle_log.interface_path('selector')

    # @return [Array<Integer>]
    def selector_position = [0, 0]

    # Max width for the log message before truncation happens
    def max_text_width = text_dimensions[0] - 6

    # @return [String]
    def truncator_filename = Configs.zv_battle_log.interface_path('truncator')

    # @return [Array<Integer>]
    def truncator_position = [text_position[0] + max_text_width + 2, 7]
  end
end
