class FusionQuizAppScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(main_menu_scene, screen)
    @main_menu_scene = main_menu_scene
    @screen = screen

    loop do
      btn_play  = FusionQuizMenuButton.new("play",  nil, "Play")
      btn_score = FusionQuizMenuButton.new("score", nil, "Score")
      btn_close = FusionQuizMenuButton.new("exit",  nil, "Exit")

      @scene.pbStartScene([btn_play, btn_score, btn_close])
      @scene.pbScene

      case @scene.selected_action
      when :play
        @scene.pbEndSceneKeepBg
        launch_quiz
        @scene.playing = false
        @scene.disposeBg
      when :score
        @scene.pbEndSceneKeepBg
        show_high_score
        @scene.disposeBg
      when :exit, nil
        @scene.pbEndScene
        break
      end
    end
  end

  def launch_quiz
    difficulty = prompt_difficulty
    high_score = pbGet(VAR_STAT_FUSION_QUIZ_HIGHEST_SCORE)
    @scene.difficulty = difficulty
    if difficulty
      nb_rounds = prompt_nb_rounds
      if nb_rounds > 0
        @scene.playing = true
        @scene.updateBackground
        quiz = FusionQuiz.new(difficulty)
        quiz.silhouette_color = Color.new(0, 0, 0, 200)
        quiz.windowed = false
        if difficulty == :ADVANCED
          quiz.picture_offset_x = -30
          quiz.picture_offset_y = 32
        else
          quiz.picture_offset_x = -40
          quiz.picture_offset_y = 32
        end
        quiz.start_quiz(nb_rounds)
        unless quiz.player_abandonned
          score = quiz.get_score
          if score > high_score
            pbMEPlay("Level Up")
            pbMessage(_INTL("You beat your previous high score!", score))
          end
        end
      end
    end
  end

  def prompt_difficulty
    choice = pbMessage(
      _INTL("Choose a difficulty:"),
      [_INTL("Regular"), _INTL("Advanced"), _INTL("Cancel")],3
    )
    echoln choice
    case choice
    when 0
      return :REGULAR
    when 1
      return :ADVANCED
    else
      return nil
    end
  end

  def prompt_nb_rounds
    choice = pbMessage(
      _INTL("Choose the number of rounds:"),
      [_INTL("3 Rounds"),
       _INTL("5 Rounds"),
       _INTL("10 Rounds"),
       _INTL("Cancel")
      ],4
    )
    echoln choice
    possible_rounds = [3,5,10,0]
    return possible_rounds[choice]
  end

  def show_high_score
    high = pbGet(VAR_STAT_FUSION_QUIZ_HIGHEST_SCORE)
    total = pbGet(VAR_STAT_FUSION_QUIZ_TOTAL_PTS)
    times = pbGet(VAR_STAT_FUSION_QUIZ_NB_TIMES)
    pbMessage(_INTL("High Score: {1} pts", high))
    pbMessage(_INTL("Total Points: {1}\\nGames Played: {2}", total, times))
  end
end