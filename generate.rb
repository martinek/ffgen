get '/' do
  '

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Create epub from story on fanfiction.com">
    <meta name="author" content="montas<montas@freevision.sk>">
    <title>Fanfic epub generator</title>

    <!-- Bootstrap core CSS -->
    <link href="//netdna.bootstrapcdn.com/bootstrap/3.0.2/css/bootstrap.min.css" rel="stylesheet">

    <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
      <script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
    <![endif]-->
  </head>

  <body>

    <style>
      body {
        padding-top: 40px;
        padding-bottom: 40px;
        background-color: #eee;
      }

      .form {
        max-width: 500px;
        padding: 15px;
        margin: 0 auto;
      }

      .form .form-heading {
        text-align: center;
        margin-bottom: 10px;
      }

      .form textarea {
        height: 600px;
      }
    </style>

    <div class="container">

      <form class="form" action="story.epub" method="post">
        <h2 class="form-heading">Url:</h2>
        <input name="url" class="form-control" placeholder="https://www.fanfiction.com/s/#story_id" required autofocus />
        <button class="btn btn-lg btn-primary btn-block" type="submit">Generate .epub!</button>
      </form>

    </div> <!-- /container -->
  </body>
</html>

'
end

post '/story.epub' do
  content_type 'application/epub+zip'

  story = FanficStory.new(params['url'])
  story.load_details
  story.load_chapters

  gen = Generator.new
  gen.build(story)
  gen.result_stream.string
end
