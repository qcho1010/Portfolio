/* Kyu Cho
2261 project4
12/19/14
Description: Battleship
1. Create Frame, label, and array of button with actionlistener
2. Once the button action listener is triggered, it will check for miss and hit
3. The ship will ends once all the spots are hit*/

import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import javax.swing.*;

public class BattleShip extends JFrame {
	public static JButton[][] btn = new JButton[10][10];
	public static int[][] ship = new int[10][10];
	public static int hitScore, missScore, sunkScore;
	public static String hitScoreS = Integer.toString(hitScore),
						 missScoreS = Integer.toString(missScore), 
						 sunkScoreS = Integer.toString(sunkScore);
	public static JLabel jlblHitNum = new JLabel(hitScoreS, JLabel.CENTER),
						 jlblMissNum = new JLabel(missScoreS, JLabel.CENTER),
						 jlblSunkNum = new JLabel(sunkScoreS, JLabel.CENTER);

	public static void main(String[] args) {
		BattleShip frame = new BattleShip();
		frame.setTitle("Battle-ship");
		frame.setSize(550, 500);
		frame.setLocationRelativeTo(null);
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		frame.setVisible(true);
		setShip();
	}
	public BattleShip() {
		JPanel p1 = new JPanel();
		p1.setLayout(new GridLayout(11, 11));
		int c = 0, r = 0;
		for (r = 0; r < 10; r++) {
			for (c = 0; c < 10; c++) {
				btn[c][r] = new JButton("~~");
				btn[c][r].setBackground(Color.BLUE);
				btn[c][r].addActionListener(new BtnListener(c, r));
				p1.add(btn[c][r]);
			}
		}		
		JPanel p2 = new JPanel();
		p2.setLayout(new GridLayout(6, 1));
		p2.add(new JLabel("Hit", JLabel.CENTER));
		p2.add(jlblHitNum);
		p2.add(new JLabel("Miss", JLabel.CENTER));
		p2.add(jlblMissNum);
		p2.add(new JLabel("Sunk", JLabel.CENTER));
		p2.add(jlblSunkNum);

		JPanel p3 = new JPanel();
		p3.setLayout(new FlowLayout());
		JLabel tryIt = new JLabel("Try to sink my battleship");
		p3.add(tryIt);

		add(p1, BorderLayout.EAST);
		add(p2, BorderLayout.WEST);
		add(p3, BorderLayout.NORTH);
	}
	private static class BtnListener implements ActionListener {
		private int c, r;		
		public BtnListener(int c, int r) {
			this.c = c;
			this.r = r;
		}		
		public void actionPerformed(ActionEvent e) {
			if (ship[c][r] == 1) {
				ship[c][r] = 0;
				btn[c][r].setBackground(Color.RED);
				hitScore++;
				String hitScoreS = Integer.toString(hitScore);
				jlblHitNum.setText(hitScoreS);
				if (hitScore % 6 == 0) {
					sunkScore++;
					String sunkScoreS = Integer.toString(sunkScore);
					jlblSunkNum.setText(sunkScoreS);
					JOptionPane.showMessageDialog(null,
							"You sunk the battleship~!!");
				}
			} else if (ship[c][r] == 0) {
				btn[c][r].setBackground(Color.CYAN);
				missScore++;
				String missScoreS = Integer.toString(missScore);
				jlblMissNum.setText(missScoreS);
			}
		}
	}
	private static void setShip() {
		int left=0, right=0, up=0, down=0,
			cols = (int) (Math.random() * 9) + 0,
			rows = (int) (Math.random() * 9) + 0,
			direction = (int) (Math.random() * 2) + 1;		
		//Check boundary
		if (cols + 5 > 9)
			left = 1;
		else if (cols - 5 < 0)
			right = 1;
		if (rows + 5 > 9)
			up = 1;
		else if (rows - 5 < 0)
			down = 1;			
		//Set Direction
		if (left == 1 && down == 1) {
			if (direction == 1) {
				down = 0;
				direction = 1;
			} else if (direction == 2) {
				left = 0;
				direction = 3;
			}
		} else if (right == 1 && down == 1) {
			if (direction == 1) {
				down = 0;
				direction = 2;
			} else if (direction == 2) {
				right = 0;
				direction = 3;
			}
		} else if (left == 1 && up == 1) {
			if (direction == 1) {
				up = 0;
				direction = 1;
			} else if (direction == 2) {
				left = 0;
				direction = 4;
			}
		} else if (right == 1 && up == 1) {
			if (direction == 1) {
				up = 0;
				direction = 2;
			} else if (direction == 2) {
				right = 0;
				direction = 4;
			}
		}		
		//Build Ship
		switch (direction) {
		case 1:
			for (int i = 0; i < 6; i++)
				ship[cols - i][rows] = 1;
			break;
		case 2:
			for (int i = 0; i < 6; i++)
				ship[cols + i][rows] = 1;
			break;
		case 3:
			for (int i = 0; i < 6; i++)
				ship[cols][rows + i] = 1;
			break;
		case 4:
			for (int i = 0; i < 6; i++)
				ship[cols][rows - i] = 1;
			break;
		}
	}
}
