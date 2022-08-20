ARG ssh_pubkey

FROM ubuntu:22.04

RUN apt-get update && apt-get install -y x11-apps openssh-server
RUN grep -q "ChallengeResponseAuthentication" /etc/ssh/sshd_config && sed -i "/^[^#]*ChallengeResponseAuthentication[[:space:]]yes.*/c\ChallengeResponseAuthentication no" /etc/ssh/sshd_config || echo "ChallengeResponseAuthentication no" >> /etc/ssh/sshd_config
RUN grep -q "^[^#]*PasswordAuthentication" /etc/ssh/sshd_config && sed -i "/^[^#]*PasswordAuthentication[[:space:]]yes/c\PasswordAuthentication no" /etc/ssh/sshd_config || echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
RUN mkdir /var/run/sshd

RUN mkdir -p /home/developer && \
	echo "developer:x:1000:1000:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
	echo "developer:x:1000:" >> /etc/group
RUN mkdir /home/developer/.ssh
RUN echo ${ssh_pubkey} >> /home/developer/.ssh/known_hosts

RUN chown -R developer /home/developer && chmod -R 744 /home/developer

# Replace 1000 with your user / group id
# RUN mkdir -p /home/developer && \
#     # echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
#     # chmod 0440 /etc/sudoers.d/developer && \
#     chown ${uid}:${gid} -R /home/developer
# 
# USER developer
# ENV HOME /home/developer

RUN service ssh restart
EXPOSE 22
CMD ["/usr/sbin/sshd", "-d"]
