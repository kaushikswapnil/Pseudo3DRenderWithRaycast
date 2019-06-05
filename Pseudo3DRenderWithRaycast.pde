ArrayList<Shape> obstacles;
CameraParticle particle;

float screen1Width = 400;
float screen1Height = 800;

float screen2Width = 400;
float screen2Height = 800;

float wallHeight = 300;

float camRotationAngle = PI/24;

void setup()
{
  size(1200, 800);
  
  screen1Width = screen2Width = width/2;
  screen1Height = screen2Height = height;

  obstacles = new ArrayList<Shape>();
  
  int numObs = (int)random(5, 20);
  
  for (int iter = 0; iter < numObs; ++iter)
  {
     if (random(2) - 1 < 0)
     {
       obstacles.add(new Line(new PVector(random(screen1Width), random(screen1Height)), new PVector(random(screen1Width), random(screen1Height))));
     }
     else
     {
       float radius = random(10, 80);
       obstacles.add(new Circle(new PVector(random(radius, screen1Width - radius), random(radius, screen1Height - radius)), radius));
       //obstacles.add(new Circle(new PVector(width - 50, height/2), 50));//random(10, 80)));
     }
  }
  
  //Boundary obstacles
  obstacles.add(new Line(new PVector(0, 0), new PVector(0, screen1Height)));
  obstacles.add(new Line(new PVector(0, 0), new PVector(screen1Width, 0)));
  obstacles.add(new Line(new PVector(screen1Width, 0), new PVector(screen1Width, screen1Height)));
  obstacles.add(new Line(new PVector(0, screen1Height), new PVector(screen1Width, screen1Height)));
  
  particle = new CameraParticle(PVector.fromAngle(0), screen1Width/2, screen1Height/2, 20, PI/3, 200);
}

void draw()
{
   background(0); 
   
   //particle.m_Position.x = mouseX;
   //particle.m_Position.y = mouseY;
   
   particle.Display();
   
   particle.Update(obstacles);
   
   for (Shape shape : obstacles)
   {
      shape.Display(); 
   }
}

void keyPressed()
{
   if (key == 'a' || key == 'A')
   {
     particle.Rotate(-camRotationAngle);
   }
   else if (key == 'd' || key == 'D')
   {
     particle.Rotate(camRotationAngle);
   }
   else if(key == 'w' || key == 'W')
   {
     particle.ChangeFOV(camRotationAngle); 
   }
   else if(key == 's' || key == 'S')
   {
     particle.ChangeFOV(-camRotationAngle); 
   }
}

boolean IsNullWithEpsilon(float value)
{
  return abs(value - 0.0) <= EPSILON;
}

boolean IsGreaterWithEpsilon(float a, float b)
{
  return (a - b) > EPSILON;
}

boolean IsLesserWithEpsilon(float a, float b)
{
  return (a - b) < EPSILON;
}

boolean IsEqualWithEpsilon(float a, float b)
{
  return IsNullWithEpsilon(a-b); 
}

boolean IsGreaterOrEqualWithEpsilon(float a, float b)
{
   return IsGreaterWithEpsilon(a, b) || IsEqualWithEpsilon(a, b); 
}

boolean IsLesserOrEqualWithEpsilon(float a, float b)
{
   return IsLesserWithEpsilon(a, b) || IsEqualWithEpsilon(a, b); 
}

float Limit(float value, float min, float max)
{
   if (IsLesserWithEpsilon(value, min))
   {
      value = min; 
   }
   else if(IsGreaterWithEpsilon(value, max))
   {
      value = max; 
   }
   
   return value;
}
