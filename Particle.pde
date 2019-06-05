class Particle
{
   PVector m_Position;
   float m_Radius;
   
   ArrayList<Ray> m_Rays;
   
   Particle(float posX, float posY, float radius) //for derived class calls
   {
     m_Position = new PVector(posX, posY);
     m_Radius = radius;
     
     m_Rays = new ArrayList<Ray>();
   }
   
   Particle(float posX, float posY, float radius, int numRays)
   {
     m_Position = new PVector(posX, posY);
     m_Radius = radius;
     
     m_Rays = new ArrayList<Ray>();
     
     float angleIncrement = TWO_PI/numRays;
     
     for(float iter = 0; iter < TWO_PI; iter += angleIncrement)
     {
        m_Rays.add(new Ray(m_Position, PVector.fromAngle(iter))); 
     }
   }
   
   void Display()
   {
      stroke(255);
      fill(255);
      ellipse(m_Position.x, m_Position.y, m_Radius, m_Radius);
   }
   
   void UpdatePos()
   {
      m_Position.x = Limit(mouseX, 0, screen1Width);
      m_Position.y = Limit(mouseY, 0, screen1Height);
      
      for (Ray ray : m_Rays)
      {
         ray.m_StartPos.x = m_Position.x;
         ray.m_StartPos.y = m_Position.y;
      }
   }
   
   void Update(ArrayList<Shape> shapes)
   {
      UpdatePos();
     
      Display(); 
     
      ContactPoint testContactPoint = new ContactPoint(0, 0);
      for (Ray ray : m_Rays)
      {
         if (ray.Cast(shapes, testContactPoint))
         {
           stroke(255, 120);
           //point(testContactPoint.m_Position.x, testContactPoint.m_Position.y);
           line(m_Position.x, m_Position.y, testContactPoint.m_Position.x, testContactPoint.m_Position.y);
         }
      }
   }
}
